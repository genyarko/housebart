# Accommodation Bartering System - Supabase Implementation

## Table of Contents
1. [Supabase Architecture Overview](#supabase-architecture-overview)
2. [Database Schema](#database-schema)
3. [Authentication Setup](#authentication-setup)
4. [Row Level Security (RLS)](#row-level-security)
5. [Real-time Subscriptions](#real-time-subscriptions)
6. [Storage Configuration](#storage-configuration)
7. [Edge Functions](#edge-functions)
8. [Flutter Integration](#flutter-integration)
9. [Deployment Guide](#deployment-guide)

## Supabase Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                 Flutter Mobile App                   │
│              (iOS/Android/Web/Desktop)              │
└─────────────────────────────────────────────────────┘
                           │
                    Supabase Client SDK
                           │
┌─────────────────────────────────────────────────────┐
│                   Supabase Platform                  │
├──────────────────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │   Auth     │  │  Database  │  │  Storage   │   │
│  │  (GoTrue)  │  │(PostgreSQL)│  │   (S3)     │   │
│  └────────────┘  └────────────┘  └────────────┘   │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │ Realtime   │  │    Edge    │  │   Vector   │   │
│  │(WebSockets)│  │ Functions  │  │  (pgvector)│   │
│  └────────────┘  └────────────┘  └────────────┘   │
└─────────────────────────────────────────────────────┘
```

## Database Schema

### SQL Migration Files

Create these tables in your Supabase SQL editor:

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create custom types
CREATE TYPE user_role AS ENUM ('user', 'verifier', 'admin');
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
CREATE TYPE property_type AS ENUM ('apartment', 'house', 'villa', 'condo', 'cabin', 'other');
CREATE TYPE barter_status AS ENUM ('pending', 'accepted', 'rejected', 'cancelled', 'completed');
CREATE TYPE payment_status AS ENUM ('pending', 'paid', 'failed', 'refunded');

-- Users Profile table (extends Supabase auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  role user_role DEFAULT 'user',
  is_verified BOOLEAN DEFAULT false,
  stripe_customer_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Properties table
CREATE TABLE public.properties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state_province TEXT,
  country TEXT NOT NULL,
  postal_code TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location GEOGRAPHY(POINT),
  property_type property_type DEFAULT 'other',
  max_guests INTEGER NOT NULL DEFAULT 2,
  bedrooms INTEGER NOT NULL DEFAULT 1,
  bathrooms INTEGER NOT NULL DEFAULT 1,
  area_sqft INTEGER,
  amenities TEXT[] DEFAULT '{}',
  house_rules TEXT[] DEFAULT '{}',
  verification_status verification_status DEFAULT 'unverified',
  average_rating DECIMAL(3, 2),
  total_reviews INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create spatial index for location-based queries
CREATE INDEX idx_properties_location ON properties USING GIST(location);
CREATE INDEX idx_properties_owner ON properties(owner_id);
CREATE INDEX idx_properties_city_country ON properties(city, country);
CREATE INDEX idx_properties_verification ON properties(verification_status);

-- Property Images table
CREATE TABLE public.property_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  caption TEXT,
  is_primary BOOLEAN DEFAULT false,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Property Availability table
CREATE TABLE public.property_availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_date_range CHECK (end_date >= start_date)
);

-- Create index for availability searches
CREATE INDEX idx_availability_property_dates ON property_availability(property_id, start_date, end_date);

-- Barter Requests table
CREATE TABLE public.barter_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID NOT NULL REFERENCES auth.users(id),
  offer_property_id UUID NOT NULL REFERENCES properties(id),
  target_property_id UUID NOT NULL REFERENCES properties(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  guest_count INTEGER NOT NULL DEFAULT 1,
  status barter_status DEFAULT 'pending',
  message TEXT,
  rejection_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT valid_barter_dates CHECK (end_date >= start_date),
  CONSTRAINT different_properties CHECK (offer_property_id != target_property_id)
);

CREATE INDEX idx_barter_requester ON barter_requests(requester_id);
CREATE INDEX idx_barter_offer_property ON barter_requests(offer_property_id);
CREATE INDEX idx_barter_target_property ON barter_requests(target_property_id);
CREATE INDEX idx_barter_status ON barter_requests(status);

-- Messages table
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  barter_request_id UUID NOT NULL REFERENCES barter_requests(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_barter ON messages(barter_request_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);

-- Verification Requests table
CREATE TABLE public.verification_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  requester_id UUID NOT NULL REFERENCES auth.users(id),
  verifier_id UUID REFERENCES auth.users(id),
  payment_intent_id TEXT,
  payment_status payment_status DEFAULT 'pending',
  amount DECIMAL(10, 2) NOT NULL DEFAULT 49.99,
  verification_notes TEXT,
  documents TEXT[] DEFAULT '{}',
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Reviews table
CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  barter_request_id UUID NOT NULL REFERENCES barter_requests(id),
  reviewer_id UUID NOT NULL REFERENCES auth.users(id),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  cleanliness_rating INTEGER CHECK (cleanliness_rating >= 1 AND cleanliness_rating <= 5),
  accuracy_rating INTEGER CHECK (accuracy_rating >= 1 AND accuracy_rating <= 5),
  communication_rating INTEGER CHECK (communication_rating >= 1 AND communication_rating <= 5),
  location_rating INTEGER CHECK (location_rating >= 1 AND location_rating <= 5),
  value_rating INTEGER CHECK (value_rating >= 1 AND value_rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_review_per_barter UNIQUE (barter_request_id, reviewer_id)
);

CREATE INDEX idx_reviews_property ON reviews(property_id);
CREATE INDEX idx_reviews_reviewer ON reviews(reviewer_id);

-- Saved Properties (Favorites) table
CREATE TABLE public.saved_properties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_saved_property UNIQUE (user_id, property_id)
);

-- Notifications table
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_properties_updated_at BEFORE UPDATE ON properties
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_barter_requests_updated_at BEFORE UPDATE ON barter_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_verification_requests_updated_at BEFORE UPDATE ON verification_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Row Level Security (RLS)

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE barter_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Properties policies
CREATE POLICY "Properties are viewable by everyone"
  ON properties FOR SELECT
  USING (is_active = true);

CREATE POLICY "Users can create properties"
  ON properties FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update own properties"
  ON properties FOR UPDATE
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can delete own properties"
  ON properties FOR DELETE
  USING (auth.uid() = owner_id);

-- Property images policies
CREATE POLICY "Property images are viewable by everyone"
  ON property_images FOR SELECT
  USING (true);

CREATE POLICY "Property owners can manage images"
  ON property_images FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM properties
      WHERE properties.id = property_images.property_id
      AND properties.owner_id = auth.uid()
    )
  );

-- Barter requests policies
CREATE POLICY "Users can view their own barter requests"
  ON barter_requests FOR SELECT
  USING (
    auth.uid() = requester_id OR
    EXISTS (
      SELECT 1 FROM properties
      WHERE properties.id = barter_requests.target_property_id
      AND properties.owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can create barter requests"
  ON barter_requests FOR INSERT
  WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "Users can update their own barter requests"
  ON barter_requests FOR UPDATE
  USING (
    auth.uid() = requester_id OR
    EXISTS (
      SELECT 1 FROM properties
      WHERE properties.id = barter_requests.target_property_id
      AND properties.owner_id = auth.uid()
    )
  );

-- Messages policies
CREATE POLICY "Users can view messages for their barters"
  ON messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM barter_requests br
      WHERE br.id = messages.barter_request_id
      AND (
        br.requester_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM properties p
          WHERE (p.id = br.offer_property_id OR p.id = br.target_property_id)
          AND p.owner_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Users can send messages in their barters"
  ON messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM barter_requests br
      WHERE br.id = barter_request_id
      AND (
        br.requester_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM properties p
          WHERE (p.id = br.offer_property_id OR p.id = br.target_property_id)
          AND p.owner_id = auth.uid()
        )
      )
    )
  );

-- Notifications policies
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);
```

## Database Functions

```sql
-- Function to create user profile after signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, first_name, last_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'last_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to search properties by location
CREATE OR REPLACE FUNCTION search_properties_nearby(
  lat DECIMAL,
  lng DECIMAL,
  radius_km INTEGER DEFAULT 50
)
RETURNS SETOF properties AS $$
BEGIN
  RETURN QUERY
  SELECT p.*
  FROM properties p
  WHERE ST_DWithin(
    p.location::geography,
    ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
    radius_km * 1000
  )
  AND p.is_active = true
  ORDER BY p.location <-> ST_SetSRID(ST_MakePoint(lng, lat), 4326);
END;
$$ LANGUAGE plpgsql;

-- Function to check property availability
CREATE OR REPLACE FUNCTION check_property_availability(
  property_uuid UUID,
  check_start_date DATE,
  check_end_date DATE
)
RETURNS BOOLEAN AS $$
DECLARE
  is_available BOOLEAN;
BEGIN
  -- Check if property has any availability entries for the date range
  SELECT EXISTS (
    SELECT 1
    FROM property_availability pa
    WHERE pa.property_id = property_uuid
    AND pa.is_available = true
    AND pa.start_date <= check_start_date
    AND pa.end_date >= check_end_date
  ) INTO is_available;
  
  -- Also check if there are no accepted barters for this period
  IF is_available THEN
    SELECT NOT EXISTS (
      SELECT 1
      FROM barter_requests br
      WHERE (br.offer_property_id = property_uuid OR br.target_property_id = property_uuid)
      AND br.status = 'accepted'
      AND br.start_date <= check_end_date
      AND br.end_date >= check_start_date
    ) INTO is_available;
  END IF;
  
  RETURN is_available;
END;
$$ LANGUAGE plpgsql;

-- Function to update property ratings after new review
CREATE OR REPLACE FUNCTION update_property_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE properties
  SET 
    average_rating = (
      SELECT AVG(rating)::DECIMAL(3,2)
      FROM reviews
      WHERE property_id = NEW.property_id
    ),
    total_reviews = (
      SELECT COUNT(*)
      FROM reviews
      WHERE property_id = NEW.property_id
    )
  WHERE id = NEW.property_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_property_rating_trigger
  AFTER INSERT OR UPDATE ON reviews
  FOR EACH ROW EXECUTE FUNCTION update_property_rating();

-- Function to create notification
CREATE OR REPLACE FUNCTION create_notification(
  user_uuid UUID,
  title_text TEXT,
  message_text TEXT,
  type_text TEXT,
  related_uuid UUID DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  notification_id UUID;
BEGIN
  INSERT INTO notifications (user_id, title, message, type, related_id)
  VALUES (user_uuid, title_text, message_text, type_text, related_uuid)
  RETURNING id INTO notification_id;
  
  RETURN notification_id;
END;
$$ LANGUAGE plpgsql;
```

## Edge Functions

### Create verification payment (supabase/functions/create-verification-payment/index.ts)
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@12.18.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') as string, {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: { headers: { Authorization: req.headers.get('Authorization')! } },
      }
    )

    // Get user
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const { propertyId } = await req.json()

    // Verify property ownership
    const { data: property } = await supabaseClient
      .from('properties')
      .select('*')
      .eq('id', propertyId)
      .single()

    if (property.owner_id !== user.id) {
      return new Response(
        JSON.stringify({ error: 'You can only verify your own properties' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Stripe payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 4999, // $49.99 in cents
      currency: 'usd',
      metadata: {
        propertyId,
        userId: user.id,
      },
    })

    // Create verification request
    const { data: verificationRequest, error } = await supabaseClient
      .from('verification_requests')
      .insert({
        property_id: propertyId,
        requester_id: user.id,
        payment_intent_id: paymentIntent.id,
        payment_status: 'pending',
      })
      .select()
      .single()

    if (error) {
      throw error
    }

    return new Response(
      JSON.stringify({
        clientSecret: paymentIntent.client_secret,
        verificationRequestId: verificationRequest.id,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
```

### Handle webhook (supabase/functions/stripe-webhook/index.ts)
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@12.18.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') as string, {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

serve(async (req) => {
  const signature = req.headers.get('stripe-signature')
  const body = await req.text()
  
  try {
    const event = stripe.webhooks.constructEvent(
      body,
      signature!,
      Deno.env.get('STRIPE_WEBHOOK_SECRET')!
    )

    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object as Stripe.PaymentIntent
        
        // Update verification request
        await supabase
          .from('verification_requests')
          .update({ 
            payment_status: 'paid',
            updated_at: new Date().toISOString()
          })
          .eq('payment_intent_id', paymentIntent.id)
        
        // Update property verification status
        const propertyId = paymentIntent.metadata.propertyId
        await supabase
          .from('properties')
          .update({ 
            verification_status: 'pending',
            updated_at: new Date().toISOString()
          })
          .eq('id', propertyId)
        
        // Create notification
        const userId = paymentIntent.metadata.userId
        await supabase
          .from('notifications')
          .insert({
            user_id: userId,
            title: 'Verification Payment Received',
            message: 'Your verification request is being processed.',
            type: 'verification',
            related_id: propertyId
          })
        
        break
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 400 }
    )
  }
})
```

## Flutter Integration

### pubspec.yaml
```yaml
name: barter_app
description: Accommodation bartering system with Supabase
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # Supabase
  supabase_flutter: ^2.3.0
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.0
  
  # UI Components
  cached_network_image: ^3.3.0
  flutter_map: ^5.0.0
  latlong2: ^0.9.0
  image_picker: ^1.0.4
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.1.0
  
  # Payments
  flutter_stripe: ^9.5.0
  
  # Notifications
  flutter_local_notifications: ^16.1.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Initialize Stripe
  Stripe.publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const BarterApp());
}

class BarterApp extends StatelessWidget {
  const BarterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Get Supabase client
final supabase = Supabase.instance.client;
```

### Authentication Service
```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  // Sign up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
      },
    );
  }
  
  // Sign in
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
```

### Property Service
```dart
// lib/services/property_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PropertyService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Create property
  Future<Map<String, dynamic>> createProperty({
    required String title,
    required String description,
    required String address,
    required String city,
    required String country,
    required double latitude,
    required double longitude,
    required String propertyType,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    required List<String> amenities,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final response = await _supabase
      .from('properties')
      .insert({
        'owner_id': user.id,
        'title': title,
        'description': description,
        'address': address,
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'location': 'POINT($longitude $latitude)',
        'property_type': propertyType,
        'max_guests': maxGuests,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'amenities': amenities,
      })
      .select()
      .single();
    
    return response;
  }
  
  // Upload property images
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<XFile> images,
  }) async {
    final List<String> imageUrls = [];
    
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      final bytes = await image.readAsBytes();
      final fileName = '${propertyId}/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Upload to Supabase Storage
      final storageResponse = await _supabase.storage
        .from('property-images')
        .uploadBinary(fileName, bytes);
      
      // Get public URL
      final imageUrl = _supabase.storage
        .from('property-images')
        .getPublicUrl(fileName);
      
      // Save image record
      await _supabase
        .from('property_images')
        .insert({
          'property_id': propertyId,
          'image_url': imageUrl,
          'storage_path': fileName,
          'is_primary': i == 0,
          'order_index': i,
        });
      
      imageUrls.add(imageUrl);
    }
    
    return imageUrls;
  }
  
  // Search properties
  Future<List<Map<String, dynamic>>> searchProperties({
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
  }) async {
    var query = _supabase
      .from('properties')
      .select('''
        *,
        property_images!inner(*),
        profiles!inner(*)
      ''')
      .eq('is_active', true);
    
    if (city != null) {
      query = query.ilike('city', '%$city%');
    }
    
    if (country != null) {
      query = query.eq('country', country);
    }
    
    if (minGuests != null) {
      query = query.gte('max_guests', minGuests);
    }
    
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Get nearby properties
  Future<List<Map<String, dynamic>>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
  }) async {
    final response = await _supabase
      .rpc('search_properties_nearby', params: {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
      });
    
    return List<Map<String, dynamic>>.from(response);
  }
}
```

### Barter Service
```dart
// lib/services/barter_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class BarterService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Create barter request
  Future<Map<String, dynamic>> createBarterRequest({
    required String offerPropertyId,
    required String targetPropertyId,
    required DateTime startDate,
    required DateTime endDate,
    required int guestCount,
    String? message,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final response = await _supabase
      .from('barter_requests')
      .insert({
        'requester_id': user.id,
        'offer_property_id': offerPropertyId,
        'target_property_id': targetPropertyId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'guest_count': guestCount,
        'message': message,
        'status': 'pending',
      })
      .select()
      .single();
    
    return response;
  }
  
  // Get user's barter requests
  Future<List<Map<String, dynamic>>> getMyBarterRequests() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    final response = await _supabase
      .from('barter_requests')
      .select('''
        *,
        offer_property:properties!offer_property_id(*),
        target_property:properties!target_property_id(*)
      ''')
      .eq('requester_id', user.id)
      .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Get received barter requests
  Future<List<Map<String, dynamic>>> getReceivedBarterRequests() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    
    // First get user's properties
    final properties = await _supabase
      .from('properties')
      .select('id')
      .eq('owner_id', user.id);
    
    final propertyIds = properties.map((p) => p['id']).toList();
    
    if (propertyIds.isEmpty) return [];
    
    final response = await _supabase
      .from('barter_requests')
      .select('''
        *,
        offer_property:properties!offer_property_id(*),
        target_property:properties!target_property_id(*),
        requester:profiles!requester_id(*)
      ''')
      .in_('target_property_id', propertyIds)
      .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }
  
  // Accept barter request
  Future<void> acceptBarterRequest(String barterId) async {
    await _supabase
      .from('barter_requests')
      .update({
        'status': 'accepted',
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', barterId);
  }
  
  // Reject barter request
  Future<void> rejectBarterRequest(String barterId, String reason) async {
    await _supabase
      .from('barter_requests')
      .update({
        'status': 'rejected',
        'rejection_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', barterId);
  }
}
```

### Real-time Subscriptions
```dart
// lib/services/realtime_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class RealtimeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};
  
  // Subscribe to barter request updates
  void subscribeToBarterUpdates(String barterId, Function(Map<String, dynamic>) onUpdate) {
    final channel = _supabase
      .channel('barter-$barterId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'barter_requests',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'id',
          value: barterId,
        ),
        callback: (payload) {
          onUpdate(payload.newRecord);
        },
      )
      .subscribe();
    
    _channels['barter-$barterId'] = channel;
  }
  
  // Subscribe to new messages
  void subscribeToMessages(String barterId, Function(Map<String, dynamic>) onNewMessage) {
    final channel = _supabase
      .channel('messages-$barterId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'barter_request_id',
          value: barterId,
        ),
        callback: (payload) {
          onNewMessage(payload.newRecord);
        },
      )
      .subscribe();
    
    _channels['messages-$barterId'] = channel;
  }
  
  // Subscribe to notifications
  void subscribeToNotifications(Function(Map<String, dynamic>) onNewNotification) {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    final channel = _supabase
      .channel('notifications-${user.id}')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: user.id,
        ),
        callback: (payload) {
          onNewNotification(payload.newRecord);
        },
      )
      .subscribe();
    
    _channels['notifications'] = channel;
  }
  
  // Unsubscribe from channel
  void unsubscribe(String channelName) {
    _channels[channelName]?.unsubscribe();
    _channels.remove(channelName);
  }
  
  // Dispose all subscriptions
  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
  }
}
```

## Deployment Guide

### 1. Supabase Setup
1. Create a new Supabase project at https://supabase.com
2. Copy your project URL and anon key
3. Run all SQL migrations in the SQL editor
4. Configure authentication providers (email, Google, etc.)
5. Set up storage buckets for property images
6. Deploy edge functions using Supabase CLI

### 2. Environment Variables
Create `.env` file:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
STRIPE_PUBLISHABLE_KEY=your_stripe_pub_key
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=your_webhook_secret
```

### 3. Deploy Edge Functions
```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Deploy edge functions
supabase functions deploy create-verification-payment
supabase functions deploy stripe-webhook
```

### 4. Flutter App Deployment
```bash
# Build for iOS
flutter build ios --release

# Build for Android
flutter build appbundle --release

# Build for Web
flutter build web --release
```

## Monitoring & Analytics

Supabase provides built-in monitoring:
- Real-time dashboard
- Query performance insights
- Storage usage tracking
- Authentication analytics
- Edge function logs

## Cost Estimation

### Supabase Pricing (Pro Plan - $25/month)
- Unlimited API requests
- 500GB bandwidth
- 100GB database
- 100GB storage
- Realtime connections
- Edge functions

### Additional Costs
- Stripe: 2.9% + $0.30 per transaction
- Google Maps API: $200 free credit/month
- App Store: $99/year
- Play Store: $25 one-time

### Total Monthly Cost: ~$50-100 for MVP

This Supabase implementation provides a complete, scalable solution for your accommodation bartering system with significantly reduced complexity compared to traditional backend architecture!

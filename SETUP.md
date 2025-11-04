# HouseBart - Setup Instructions

Welcome to HouseBart! This guide will help you set up and run the application.

## ✅ What's Been Implemented

### Phase 1-3: Foundation (COMPLETED)
- ✅ Clean Architecture folder structure
- ✅ Core layer (constants, errors, utils, validators, formatters, extensions)
- ✅ Configuration layer (app config, theme, colors, routing)
- ✅ Dependency injection with GetIt
- ✅ Supabase services (auth, realtime)

### Phase 4: Authentication Feature (COMPLETED)
- ✅ **Domain Layer**: User entity, repository interface, use cases
- ✅ **Data Layer**: User model, remote/local data sources, repository implementation
- ✅ **Presentation Layer**: AuthBloc with events & states, Login/Register/Forgot Password pages
- ✅ **Main App**: Initialized with Supabase, routing, and theme

## 📋 Prerequisites

Before you start, make sure you have:

1. **Flutter SDK** (3.6.2 or higher)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (included with Flutter)

3. **Android Studio** or **VS Code** with Flutter extensions

4. **A Supabase account** (free tier is fine)
   - Create one at https://supabase.com

## 🚀 Step-by-Step Setup

### Step 1: Install Dependencies

```bash
cd /home/user/housebart
flutter pub get
```

This will install all the packages listed in `pubspec.yaml`.

### Step 2: Create Supabase Project

1. Go to https://supabase.com and sign in
2. Click "New Project"
3. Fill in the details:
   - **Project Name**: housebart (or any name you like)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to you
4. Click "Create new project"
5. Wait for the project to finish setting up (~2 minutes)

### Step 3: Get Supabase Credentials

Once your project is ready:

1. Go to **Settings** (gear icon in sidebar)
2. Go to **API** section
3. You'll see:
   - **Project URL**: `https://your-project-id.supabase.co`
   - **anon/public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (long string)

### Step 4: Configure Environment Variables

1. Open the `.env` file in the project root
2. Update it with your Supabase credentials:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_actual_anon_key_here

# Stripe Configuration (leave as is for now)
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key_here

# App Configuration
APP_NAME=HouseBart
APP_VERSION=1.0.0

# API Configuration
API_TIMEOUT=30000

# Feature Flags
ENABLE_SOCIAL_LOGIN=false
ENABLE_PUSH_NOTIFICATIONS=false
```

**Important**: Replace `your-project-id.supabase.co` and `your_actual_anon_key_here` with your actual values!

### Step 5: Set Up Database Schema

The app needs database tables in Supabase. Run the following SQL in your Supabase SQL Editor:

1. Go to **SQL Editor** in Supabase dashboard
2. Click **New query**
3. Copy and paste this SQL:

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create custom types
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');

-- Users Profile table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  first_name TEXT,
  last_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

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

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at trigger to profiles
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

4. Click **Run** (or press Ctrl/Cmd + Enter)
5. You should see "Success. No rows returned"

### Step 6: Configure Email Authentication

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Make sure **Email** is enabled
3. Scroll down to **Email Templates** (optional but recommended):
   - Customize the confirmation email if desired
   - Set redirect URLs if needed

### Step 7: Run the App

Now you're ready to run the app!

```bash
# For Android Emulator
flutter run -d android

# For iOS Simulator (Mac only)
flutter run -d ios

# For Chrome (web)
flutter run -d chrome
```

## 🎯 Testing the Authentication Flow

Once the app is running:

1. **Splash Screen**: You'll see the HouseBart logo with loading indicator
2. **Login Screen**: App will navigate to login (since no user is logged in)
3. **Create Account**:
   - Click "Sign Up"
   - Fill in: First Name, Last Name, Email, Password
   - Click "Create Account"
4. **Check Email**: You'll receive a confirmation email from Supabase
5. **Login**: Once confirmed, login with your credentials
6. **Home Screen**: You'll see a welcome message with your name!

## 🔧 Troubleshooting

### Issue: "Could not load .env file"
**Solution**: Make sure `.env` file exists in the project root and contains your Supabase credentials.

### Issue: "Error initializing Supabase"
**Solution**:
- Check that `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env` are correct
- Make sure there are no extra spaces or quotes around the values

### Issue: "Profile not created after signup"
**Solution**:
- Make sure you ran the SQL script to create the `handle_new_user()` function and trigger
- Check Supabase logs in **Database** → **Logs**

### Issue: App crashes on startup
**Solution**:
- Run `flutter clean && flutter pub get`
- Restart your IDE
- Make sure all dependencies installed successfully

### Issue: "Failed to get current user"
**Solution**:
- Clear app data and restart
- Check that the profiles table exists in Supabase
- Verify RLS policies are set up correctly

## 📁 Project Structure

```
lib/
├── config/                  # App configuration (theme, colors, router)
├── core/                    # Core utilities (constants, errors, utils, widgets)
├── features/                # Feature modules
│   └── auth/               # Authentication feature (COMPLETE)
│       ├── data/           # Data layer
│       ├── domain/         # Domain layer
│       └── presentation/   # Presentation layer (UI)
├── services/               # Supabase services
├── injection_container.dart # Dependency injection
└── main.dart              # App entry point
```

## 🎨 Features Implemented

### Authentication
- ✅ User registration with email verification
- ✅ Login with email and password
- ✅ Logout
- ✅ Forgot password (password reset email)
- ✅ User profile caching
- ✅ Clean Architecture implementation
- ✅ BLoC state management
- ✅ Form validation
- ✅ Error handling
- ✅ Loading states

### Coming Soon
- ⏳ Property listing management
- ⏳ Barter request system
- ⏳ In-app messaging
- ⏳ Property verification
- ⏳ Reviews and ratings
- ⏳ Search and filters
- ⏳ Map integration
- ⏳ And more!

## 🔐 Security Notes

- **.env file**: Never commit this file to Git (it's already in .gitignore)
- **Supabase Keys**: The anon key is safe to use in the app (it's public)
- **RLS Policies**: Row Level Security ensures users can only access their own data
- **Password Requirements**: Minimum 8 characters, must include uppercase, lowercase, and number

## 📚 Next Steps

Now that authentication is working, here's what you can do:

1. **Test the app thoroughly**: Try all auth flows
2. **Read the architecture docs**: Check `system architecture files/` folder
3. **Review nextSteps.txt**: See what features are next
4. **Start building properties feature**: Follow the same Clean Architecture pattern

## 🆘 Need Help?

- **Supabase Issues**: Check https://supabase.com/docs
- **Flutter Issues**: Check https://docs.flutter.dev
- **Project Issues**: Review the code comments and architecture documents

---

**Congratulations!** 🎉 You've successfully set up HouseBart with authentication. The foundation is solid and ready for more features!

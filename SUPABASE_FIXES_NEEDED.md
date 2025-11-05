# Supabase Setup - Required Fixes and Missing Pieces

## Issues Found Between SQL and Flutter Code

### 1. **CRITICAL: Messages Table Mismatch**
**Problem:** 
- SQL has: `barter_request_id` 
- Flutter code expects: `barter_id`

**Fix:** Run this SQL to add the column:
```sql
ALTER TABLE messages RENAME COLUMN barter_request_id TO barter_id;
```

### 2. **Profiles Table - Missing full_name field**
**Problem:**
- SQL has: `first_name` and `last_name`
- Flutter code expects: `full_name`

**Fix:** Run this SQL:
```sql
ALTER TABLE profiles ADD COLUMN full_name TEXT;

-- Optionally migrate existing data
UPDATE profiles SET full_name = CONCAT(first_name, ' ', last_name) WHERE full_name IS NULL;
```

### 3. **Verification Requests Table - Missing Fields**
**Problem:**
- Flutter code expects: `status`, `currency`, `admin_notes`, `rejection_reason`, `expires_at`
- SQL only has: `payment_status`, `verification_notes`

**Fix:** Run this SQL:
```sql
ALTER TABLE verification_requests 
  ADD COLUMN status TEXT DEFAULT 'pending',
  ADD COLUMN currency TEXT DEFAULT 'USD',
  ADD COLUMN admin_notes TEXT,
  ADD COLUMN rejection_reason TEXT,
  ADD COLUMN expires_at TIMESTAMPTZ;

-- Set default expiration (1 year from verification)
CREATE OR REPLACE FUNCTION set_verification_expiry()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND NEW.expires_at IS NULL THEN
    NEW.expires_at = NOW() + INTERVAL '1 year';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_verification_expiry_trigger
  BEFORE UPDATE ON verification_requests
  FOR EACH ROW EXECUTE FUNCTION set_verification_expiry();
```

### 4. **Reviews Table - Simplified Fields**
**Problem:**
- SQL has detailed sub-ratings (cleanliness_rating, accuracy_rating, etc.)
- Flutter code only uses basic `rating` and `comment`

**Solution:** The SQL is more detailed (which is good!). You can either:
- **Option A:** Keep SQL as is and enhance Flutter code later
- **Option B:** Simplify SQL to match Flutter (not recommended)

**Recommended:** Keep the detailed SQL. It's better for future features.

### 5. **Reviews Table - Missing Fields**
Flutter code expects:
```sql
ALTER TABLE reviews 
  ADD COLUMN reviewer_name TEXT,
  ADD COLUMN images TEXT[] DEFAULT '{}';
```

## Missing Components (Not in SQL)

### 1. **Storage Buckets** - Must Create Manually
In Supabase Dashboard → Storage, create:
- `property-images` (public bucket)
- `user-avatars` (public bucket)
- `verification-documents` (private bucket)

**Storage Policies:**
```sql
-- Allow authenticated users to upload property images
CREATE POLICY "Users can upload property images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'property-images');

-- Allow public read access to property images
CREATE POLICY "Public can view property images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'property-images');

-- Allow authenticated users to upload avatars
CREATE POLICY "Users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'user-avatars');

-- Allow public read access to avatars
CREATE POLICY "Public can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'user-avatars');

-- Only property owners can upload verification documents
CREATE POLICY "Owners can upload verification docs"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'verification-documents');
```

### 2. **Edge Functions** - Not Deployed Yet
The SQL file includes code samples but you need to deploy them:

**To Deploy:**
```bash
# Install Supabase CLI if not already installed
npm install -g supabase

# Login
supabase login

# Link to your project
supabase link --project-ref YOUR_PROJECT_REF

# Create function files locally
mkdir -p supabase/functions/create-verification-payment
mkdir -p supabase/functions/stripe-webhook

# Copy the TypeScript code from supabase_implementation.md into:
# - supabase/functions/create-verification-payment/index.ts
# - supabase/functions/stripe-webhook/index.ts

# Deploy
supabase functions deploy create-verification-payment
supabase functions deploy stripe-webhook
```

### 3. **Additional Index for Performance**
Add these for better query performance:
```sql
-- Index for barter requests by dates
CREATE INDEX idx_barter_dates ON barter_requests(start_date, end_date);

-- Index for messages by created_at
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- Full text search on properties
CREATE INDEX idx_properties_title_search ON properties USING gin(to_tsvector('english', title));
CREATE INDEX idx_properties_description_search ON properties USING gin(to_tsvector('english', description));
```

## Environment Variables

Update your `.env` file:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_...  # Optional for now
```

## Testing Checklist

After applying fixes:
- [ ] Run the fix SQLs above
- [ ] Create storage buckets
- [ ] Test user registration (should auto-create profile)
- [ ] Test property creation
- [ ] Test image uploads
- [ ] Test messaging
- [ ] Set up Stripe (optional, for verification payments)

## Quick Setup Script

Run all fixes at once in Supabase SQL Editor:
```sql
-- Fix 1: Rename messages column
ALTER TABLE messages RENAME COLUMN barter_request_id TO barter_id;

-- Fix 2: Add full_name to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
UPDATE profiles SET full_name = CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')) WHERE full_name IS NULL;

-- Fix 3: Add missing verification fields
ALTER TABLE verification_requests 
  ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'USD',
  ADD COLUMN IF NOT EXISTS admin_notes TEXT,
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
  ADD COLUMN IF NOT EXISTS expires_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS document_url TEXT;

-- Fix 4: Add missing review fields  
ALTER TABLE reviews 
  ADD COLUMN IF NOT EXISTS reviewer_name TEXT,
  ADD COLUMN IF NOT EXISTS images TEXT[] DEFAULT '{}';

-- Fix 5: Add performance indexes
CREATE INDEX IF NOT EXISTS idx_barter_dates ON barter_requests(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at DESC);

-- Fix 6: Add verification expiry trigger
CREATE OR REPLACE FUNCTION set_verification_expiry()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND NEW.expires_at IS NULL THEN
    NEW.expires_at = NOW() + INTERVAL '1 year';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_verification_expiry_trigger ON verification_requests;
CREATE TRIGGER set_verification_expiry_trigger
  BEFORE UPDATE ON verification_requests
  FOR EACH ROW EXECUTE FUNCTION set_verification_expiry();

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'All fixes applied successfully!';
END $$;
```

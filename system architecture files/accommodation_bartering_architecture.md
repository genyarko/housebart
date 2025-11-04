# Accommodation Bartering System - Complete Architecture

## Table of Contents
1. [System Overview](#system-overview)
2. [High-Level Architecture](#high-level-architecture)
3. [Backend Architecture](#backend-architecture)
4. [Flutter App Architecture](#flutter-app-architecture)
5. [Database Design](#database-design)
6. [API Design](#api-design)
7. [Security Architecture](#security-architecture)
8. [Payment & Verification System](#payment--verification-system)
9. [Deployment Architecture](#deployment-architecture)
10. [Development Workflow](#development-workflow)

## System Overview

### Core Features
- **User Registration & Authentication**
- **Property Listing Management**
- **Bartering/Exchange System**
- **Date Range Management**
- **Verification Service (Paid)**
- **Matching Algorithm**
- **Messaging System**
- **Review & Rating System**
- **Admin Dashboard**

### Key Actors
1. **Users**: Property owners who want to exchange accommodations
2. **Verifiers**: Company staff who verify property legitimacy
3. **Admins**: System administrators
4. **System**: Automated processes and algorithms

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Client Layer                         │
├──────────────────┬──────────────────┬──────────────────────┤
│   Flutter App    │   Web Admin      │   Verifier Portal    │
│   (iOS/Android)  │   Dashboard       │   (Web)              │
└──────────────────┴──────────────────┴──────────────────────┘
                   │                    │
                   ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway (REST/GraphQL)               │
│                    - Authentication                         │
│                    - Rate Limiting                          │
│                    - Request Routing                        │
└─────────────────────────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Microservices Layer                      │
├──────────────────┬──────────────────┬──────────────────────┤
│  User Service    │  Property Service │  Matching Service    │
├──────────────────┼──────────────────┼──────────────────────┤
│  Auth Service    │  Verification     │  Notification        │
│                  │  Service          │  Service             │
├──────────────────┼──────────────────┼──────────────────────┤
│  Payment Service │  Messaging        │  Review Service      │
│                  │  Service          │                      │
└──────────────────┴──────────────────┴──────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
├──────────────────┬──────────────────┬──────────────────────┤
│  PostgreSQL      │  Redis Cache      │  S3/Cloud Storage    │
│  (Primary DB)    │                   │  (Images/Docs)       │
├──────────────────┼──────────────────┼──────────────────────┤
│  MongoDB         │  Elasticsearch    │  Message Queue       │
│  (Messages)      │  (Search)         │  (RabbitMQ/Kafka)    │
└──────────────────┴──────────────────┴──────────────────────┘
```

## Backend Architecture

### Technology Stack
- **Language**: Node.js with TypeScript (or Python with FastAPI)
- **Framework**: NestJS (Node.js) or FastAPI (Python)
- **Database**: PostgreSQL (primary), MongoDB (messages), Redis (cache)
- **Message Queue**: RabbitMQ or Apache Kafka
- **Search**: Elasticsearch
- **Storage**: AWS S3 or Google Cloud Storage
- **Payment**: Stripe or PayPal
- **Authentication**: JWT with refresh tokens

### Microservices Breakdown

#### 1. User Service
```typescript
// Domain entities
interface User {
  id: string;
  email: string;
  profile: UserProfile;
  verificationStatus: VerificationStatus;
  createdAt: Date;
  updatedAt: Date;
}

interface UserProfile {
  firstName: string;
  lastName: string;
  phone: string;
  avatar: string;
  bio: string;
  preferences: UserPreferences;
}

// Service interface
interface IUserService {
  createUser(dto: CreateUserDto): Promise<User>;
  updateProfile(userId: string, dto: UpdateProfileDto): Promise<User>;
  getUserById(userId: string): Promise<User>;
  deleteUser(userId: string): Promise<void>;
}
```

#### 2. Property Service
```typescript
interface Property {
  id: string;
  ownerId: string;
  title: string;
  description: string;
  location: Location;
  amenities: Amenity[];
  images: string[];
  availableDates: DateRange[];
  verificationStatus: VerificationStatus;
  verificationDetails?: VerificationDetails;
}

interface IPropertyService {
  createProperty(dto: CreatePropertyDto): Promise<Property>;
  updateProperty(id: string, dto: UpdatePropertyDto): Promise<Property>;
  searchProperties(criteria: SearchCriteria): Promise<Property[]>;
  requestVerification(propertyId: string): Promise<VerificationRequest>;
}
```

#### 3. Matching Service
```typescript
interface BarterRequest {
  id: string;
  requesterId: string;
  offerPropertyId: string;
  targetPropertyId: string;
  proposedDates: DateRange;
  status: BarterStatus;
  messages: Message[];
}

interface IMatchingService {
  findMatches(propertyId: string, dates: DateRange): Promise<Property[]>;
  createBarterRequest(dto: CreateBarterDto): Promise<BarterRequest>;
  acceptBarter(barterId: string): Promise<BarterRequest>;
  rejectBarter(barterId: string): Promise<BarterRequest>;
}
```

## Flutter App Architecture

### Clean Architecture Layers

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── property/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── matching/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── messaging/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── verification/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── injection_container.dart
└── main.dart
```

### Key Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  
  # Dependency Injection
  get_it: ^7.6.0
  injectable: ^2.3.0
  
  # Network
  dio: ^5.3.2
  retrofit: ^4.0.3
  
  # Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  
  # UI Components
  cached_network_image: ^3.3.0
  flutter_map: ^5.0.0
  image_picker: ^1.0.4
  
  # Utils
  dartz: ^0.10.1
  equatable: ^2.0.5
  intl: ^0.18.1
```

### Example Feature Implementation (Authentication)

```dart
// Domain Layer - Entity
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final bool isVerified;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.isVerified,
  });
  
  @override
  List<Object?> get props => [id, email, name, isVerified];
}

// Domain Layer - Repository Interface
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(RegisterParams params);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}

// Domain Layer - Use Case
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

// Data Layer - Model
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.isVerified,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      isVerified: json['isVerified'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isVerified': isVerified,
    };
  }
}

// Presentation Layer - BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
  }
  
  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

## Database Design

### PostgreSQL Schema

```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User profiles
CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    avatar_url TEXT,
    bio TEXT,
    verification_status ENUM('unverified', 'pending', 'verified'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Properties
CREATE TABLE properties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    property_type VARCHAR(50),
    max_guests INTEGER,
    bedrooms INTEGER,
    bathrooms INTEGER,
    verification_status ENUM('unverified', 'pending', 'verified', 'rejected'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Property images
CREATE TABLE property_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    order_index INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Available dates for properties
CREATE TABLE property_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Barter requests
CREATE TABLE barter_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    requester_id UUID REFERENCES users(id),
    offer_property_id UUID REFERENCES properties(id),
    target_property_id UUID REFERENCES properties(id),
    proposed_start_date DATE NOT NULL,
    proposed_end_date DATE NOT NULL,
    status ENUM('pending', 'accepted', 'rejected', 'cancelled'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verification requests
CREATE TABLE verification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    requester_id UUID REFERENCES users(id),
    payment_id VARCHAR(255),
    payment_status ENUM('pending', 'paid', 'failed', 'refunded'),
    verification_status ENUM('pending', 'in_progress', 'completed', 'failed'),
    verifier_id UUID REFERENCES users(id),
    verification_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reviews
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES users(id),
    barter_id UUID REFERENCES barter_requests(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_properties_owner ON properties(owner_id);
CREATE INDEX idx_properties_location ON properties(latitude, longitude);
CREATE INDEX idx_properties_verification ON properties(verification_status);
CREATE INDEX idx_availability_property ON property_availability(property_id);
CREATE INDEX idx_availability_dates ON property_availability(start_date, end_date);
CREATE INDEX idx_barter_requester ON barter_requests(requester_id);
CREATE INDEX idx_barter_status ON barter_requests(status);
```

## API Design

### RESTful API Endpoints

#### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
GET    /api/v1/auth/verify-email/:token
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
```

#### Users
```
GET    /api/v1/users/profile
PUT    /api/v1/users/profile
DELETE /api/v1/users/account
POST   /api/v1/users/upload-avatar
GET    /api/v1/users/:id/public-profile
```

#### Properties
```
GET    /api/v1/properties              # List with filters
POST   /api/v1/properties              # Create new property
GET    /api/v1/properties/:id          # Get single property
PUT    /api/v1/properties/:id          # Update property
DELETE /api/v1/properties/:id          # Delete property
POST   /api/v1/properties/:id/images   # Upload images
DELETE /api/v1/properties/:id/images/:imageId
POST   /api/v1/properties/:id/availability
GET    /api/v1/properties/search       # Advanced search
```

#### Verification
```
POST   /api/v1/verification/request/:propertyId
GET    /api/v1/verification/status/:requestId
POST   /api/v1/verification/payment/:requestId
GET    /api/v1/verification/my-requests
```

#### Bartering
```
POST   /api/v1/barters/request         # Create barter request
GET    /api/v1/barters/my-requests     # Get user's requests
GET    /api/v1/barters/received        # Get received requests
PUT    /api/v1/barters/:id/accept      # Accept barter
PUT    /api/v1/barters/:id/reject      # Reject barter
PUT    /api/v1/barters/:id/cancel      # Cancel barter
GET    /api/v1/barters/:id             # Get barter details
```

#### Messaging
```
GET    /api/v1/messages/conversations  # List conversations
GET    /api/v1/messages/:barterId      # Get messages for barter
POST   /api/v1/messages/:barterId      # Send message
```

#### Reviews
```
POST   /api/v1/reviews                 # Create review
GET    /api/v1/reviews/property/:id    # Get property reviews
GET    /api/v1/reviews/user/:id        # Get user reviews
```

### API Response Format

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2024-01-01T12:00:00Z",
    "version": "1.0.0"
  }
}

// Error response
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      }
    ]
  },
  "meta": {
    "timestamp": "2024-01-01T12:00:00Z",
    "version": "1.0.0"
  }
}
```

## Security Architecture

### Authentication & Authorization
- **JWT Tokens**: Access token (15 min) + Refresh token (7 days)
- **Role-Based Access Control (RBAC)**:
  - User: Can manage own properties and barters
  - Verifier: Can verify properties
  - Admin: Full system access

### Security Measures
1. **API Security**:
   - Rate limiting (100 requests/min per IP)
   - API key validation
   - Request signing for sensitive operations
   - CORS configuration

2. **Data Security**:
   - Encryption at rest (AES-256)
   - Encryption in transit (TLS 1.3)
   - PII data encryption
   - Regular security audits

3. **Input Validation**:
   - Sanitize all inputs
   - SQL injection prevention
   - XSS protection
   - File upload validation

4. **Authentication Flow**:
```
Client -> Login Request -> API Gateway
API Gateway -> Validate Credentials -> Auth Service
Auth Service -> Generate Tokens -> Return to Client
Client -> Store Tokens Securely
Client -> Include Token in Headers -> API Requests
```

## Payment & Verification System

### Payment Flow for Verification
```
1. User requests property verification
2. System calculates verification fee
3. User redirected to payment gateway (Stripe/PayPal)
4. Payment processed
5. Verification request created with "paid" status
6. Notification sent to verification team
7. Verifier assigned to request
8. Verification completed
9. Property status updated
10. User notified of completion
```

### Stripe Integration
```typescript
// Payment service implementation
class PaymentService {
  private stripe: Stripe;
  
  constructor() {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  }
  
  async createVerificationPayment(
    propertyId: string,
    userId: string
  ): Promise<PaymentIntent> {
    const amount = this.calculateVerificationFee(propertyId);
    
    const paymentIntent = await this.stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency: 'usd',
      metadata: {
        propertyId,
        userId,
        type: 'verification'
      }
    });
    
    return paymentIntent;
  }
  
  async handleWebhook(event: Stripe.Event): Promise<void> {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await this.handleSuccessfulPayment(event.data.object);
        break;
      case 'payment_intent.payment_failed':
        await this.handleFailedPayment(event.data.object);
        break;
    }
  }
}
```

## Deployment Architecture

### Container Architecture (Docker)
```yaml
# docker-compose.yml
version: '3.8'

services:
  # API Gateway
  gateway:
    build: ./gateway
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - redis
      
  # Microservices
  user-service:
    build: ./services/user
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    
  property-service:
    build: ./services/property
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - S3_BUCKET=${S3_BUCKET}
    
  matching-service:
    build: ./services/matching
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - RABBITMQ_URL=${RABBITMQ_URL}
    
  # Databases
  postgres:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=barterdb
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    
  mongodb:
    image: mongo:6
    volumes:
      - mongo_data:/data/db
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=${MONGO_PASSWORD}
    
  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "15672:15672"
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=${RABBITMQ_PASSWORD}
    
  # Search
  elasticsearch:
    image: elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - es_data:/usr/share/elasticsearch/data

volumes:
  postgres_data:
  redis_data:
  mongo_data:
  es_data:
```

### Kubernetes Deployment (Production)
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: barter-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: gateway
        image: your-registry/api-gateway:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway-service
  namespace: barter-app
spec:
  selector:
    app: api-gateway
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

### CI/CD Pipeline (GitHub Actions)
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm ci
      - run: npm test
      - run: npm run lint
  
  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker images
        run: |
          docker build -t ${{ secrets.REGISTRY }}/api-gateway:${{ github.sha }} ./gateway
          docker build -t ${{ secrets.REGISTRY }}/user-service:${{ github.sha }} ./services/user
          
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push ${{ secrets.REGISTRY }}/api-gateway:${{ github.sha }}
          docker push ${{ secrets.REGISTRY }}/user-service:${{ github.sha }}
      
      - name: Deploy to Kubernetes
        run: |
          kubectl set image deployment/api-gateway gateway=${{ secrets.REGISTRY }}/api-gateway:${{ github.sha }}
          kubectl set image deployment/user-service user=${{ secrets.REGISTRY }}/user-service:${{ github.sha }}
```

## Development Workflow

### Git Branching Strategy
```
main
├── develop
│   ├── feature/user-authentication
│   ├── feature/property-listing
│   ├── feature/matching-algorithm
│   └── feature/payment-integration
├── release/v1.0.0
└── hotfix/critical-bug-fix
```

### Development Environment Setup

1. **Prerequisites**:
```bash
# Install required tools
- Node.js 18+
- Flutter 3.10+
- Docker Desktop
- PostgreSQL 15
- Redis
```

2. **Backend Setup**:
```bash
# Clone repository
git clone https://github.com/your-org/barter-backend.git
cd barter-backend

# Install dependencies
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Run database migrations
npm run migration:run

# Start development server
npm run dev
```

3. **Flutter App Setup**:
```bash
# Clone repository
git clone https://github.com/your-org/barter-flutter.git
cd barter-flutter

# Install dependencies
flutter pub get

# Generate code (for code generation packages)
flutter pub run build_runner build

# Run the app
flutter run
```

### Testing Strategy

#### Backend Testing
```typescript
// Unit Test Example
describe('PropertyService', () => {
  let service: PropertyService;
  let repository: MockRepository<Property>;
  
  beforeEach(() => {
    repository = new MockRepository();
    service = new PropertyService(repository);
  });
  
  it('should create a property', async () => {
    const dto = new CreatePropertyDto();
    const result = await service.create(dto);
    expect(result).toBeDefined();
    expect(repository.save).toHaveBeenCalledWith(dto);
  });
});

// Integration Test Example
describe('Property API', () => {
  it('POST /properties should create a property', async () => {
    const response = await request(app)
      .post('/api/v1/properties')
      .set('Authorization', `Bearer ${token}`)
      .send(propertyData);
    
    expect(response.status).toBe(201);
    expect(response.body.data).toHaveProperty('id');
  });
});
```

#### Flutter Testing
```dart
// Widget Test Example
void main() {
  testWidgets('Login screen shows email and password fields', 
    (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));
    
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
  });
  
  // Unit Test Example
  test('LoginBloc emits success on valid credentials', () async {
    when(mockAuthRepository.login(any, any))
      .thenAnswer((_) async => Right(user));
    
    bloc.add(LoginEvent(email: 'test@test.com', password: 'password'));
    
    await expectLater(
      bloc.stream,
      emitsInOrder([AuthLoading(), AuthSuccess(user)]),
    );
  });
}
```

### Code Quality Tools

1. **Linting**:
```json
// Backend - .eslintrc.json
{
  "extends": ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  "rules": {
    "no-unused-vars": "error",
    "no-console": "warn"
  }
}
```

```yaml
# Flutter - analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    require_trailing_commas: true
```

2. **Pre-commit Hooks**:
```json
// package.json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.ts": ["eslint --fix", "prettier --write"],
    "*.dart": ["flutter format", "flutter analyze"]
  }
}
```

## Monitoring & Analytics

### Application Monitoring
- **APM**: New Relic or DataDog
- **Error Tracking**: Sentry
- **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Metrics**: Prometheus + Grafana

### Key Metrics to Track
1. **Business Metrics**:
   - Number of active users
   - Properties listed
   - Successful barters
   - Verification requests
   - Revenue from verifications

2. **Technical Metrics**:
   - API response times
   - Error rates
   - Database query performance
   - Cache hit rates
   - Message queue throughput

### Monitoring Implementation
```typescript
// Metrics middleware
class MetricsMiddleware {
  async use(req: Request, res: Response, next: NextFunction) {
    const start = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - start;
      
      // Send metrics to monitoring service
      metrics.recordApiCall({
        path: req.path,
        method: req.method,
        statusCode: res.statusCode,
        duration
      });
    });
    
    next();
  }
}
```

## Scalability Considerations

### Horizontal Scaling
- Microservices can be scaled independently
- Load balancing across multiple instances
- Database read replicas for read-heavy operations
- Caching strategy with Redis

### Performance Optimizations
1. **Database**:
   - Proper indexing
   - Query optimization
   - Connection pooling
   - Partitioning for large tables

2. **Caching**:
   - Redis for session management
   - Cache frequently accessed data
   - CDN for static assets

3. **Async Processing**:
   - Message queues for long-running tasks
   - Background jobs for notifications
   - Event-driven architecture

### Load Testing
```bash
# Using Apache Bench
ab -n 10000 -c 100 http://api.yourapp.com/api/v1/properties

# Using k6
k6 run load-test.js
```

## Cost Estimation

### Infrastructure Costs (AWS - Monthly)
- **EC2 Instances** (3x t3.medium): $120
- **RDS PostgreSQL** (db.t3.medium): $70
- **ElastiCache Redis**: $50
- **S3 Storage** (100GB): $25
- **CloudFront CDN**: $50
- **Load Balancer**: $25
- **Estimated Total**: ~$340/month

### Third-party Services
- **Stripe**: 2.9% + $0.30 per transaction
- **SendGrid** (Email): $15-50/month
- **Twilio** (SMS): Pay as you go
- **Google Maps API**: $200 free credit/month

## Conclusion

This architecture provides a solid foundation for building a scalable accommodation bartering system. The key principles followed are:

1. **Clean Architecture**: Clear separation of concerns
2. **Microservices**: Scalable and maintainable
3. **Security First**: Authentication, authorization, and data protection
4. **Test-Driven Development**: Comprehensive testing strategy
5. **DevOps Ready**: CI/CD pipeline and containerization
6. **Monitoring**: Real-time insights and error tracking

The system is designed to handle growth while maintaining code quality and user experience. Start with the MVP features and gradually add complexity as the user base grows.

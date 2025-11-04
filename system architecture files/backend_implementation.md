# Backend API Implementation - Node.js/TypeScript/NestJS

## Project Structure

```
backend/
├── src/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.module.ts
│   │   ├── dto/
│   │   ├── guards/
│   │   └── strategies/
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.module.ts
│   │   ├── entities/
│   │   └── dto/
│   ├── properties/
│   │   ├── properties.controller.ts
│   │   ├── properties.service.ts
│   │   ├── properties.module.ts
│   │   ├── entities/
│   │   └── dto/
│   ├── barters/
│   │   ├── barters.controller.ts
│   │   ├── barters.service.ts
│   │   ├── barters.module.ts
│   │   ├── entities/
│   │   └── dto/
│   ├── verification/
│   │   ├── verification.controller.ts
│   │   ├── verification.service.ts
│   │   ├── verification.module.ts
│   │   ├── entities/
│   │   └── dto/
│   ├── messaging/
│   │   ├── messaging.gateway.ts
│   │   ├── messaging.service.ts
│   │   ├── messaging.module.ts
│   │   └── dto/
│   ├── payments/
│   │   ├── payments.service.ts
│   │   ├── payments.module.ts
│   │   └── stripe/
│   ├── common/
│   │   ├── filters/
│   │   ├── interceptors/
│   │   ├── pipes/
│   │   └── decorators/
│   ├── config/
│   │   ├── database.config.ts
│   │   ├── jwt.config.ts
│   │   └── app.config.ts
│   ├── app.module.ts
│   └── main.ts
├── test/
├── package.json
├── tsconfig.json
├── .env.example
└── docker-compose.yml
```

## Core Implementation

### 1. Package.json
```json
{
  "name": "barter-backend",
  "version": "1.0.0",
  "description": "Backend API for accommodation bartering system",
  "author": "",
  "private": true,
  "license": "MIT",
  "scripts": {
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json",
    "migration:generate": "typeorm-ts-node-commonjs migration:generate -d ./src/config/typeorm.config.ts",
    "migration:run": "typeorm-ts-node-commonjs migration:run -d ./src/config/typeorm.config.ts",
    "migration:revert": "typeorm-ts-node-commonjs migration:revert -d ./src/config/typeorm.config.ts"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/jwt": "^10.1.0",
    "@nestjs/passport": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/platform-socket.io": "^10.0.0",
    "@nestjs/swagger": "^7.1.0",
    "@nestjs/typeorm": "^10.0.0",
    "@nestjs/websockets": "^10.0.0",
    "@nestjs/bull": "^10.0.0",
    "bull": "^4.11.0",
    "bcryptjs": "^2.4.3",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.0",
    "helmet": "^7.0.0",
    "passport": "^0.6.0",
    "passport-jwt": "^4.0.1",
    "passport-local": "^1.0.0",
    "pg": "^8.11.0",
    "redis": "^4.6.0",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1",
    "stripe": "^13.0.0",
    "typeorm": "^0.3.17",
    "uuid": "^9.0.0",
    "@nestjs/cache-manager": "^2.1.0",
    "cache-manager": "^5.2.0",
    "cache-manager-redis-store": "^3.0.1",
    "@elastic/elasticsearch": "^8.9.0",
    "multer": "^1.4.5-lts.1",
    "@aws-sdk/client-s3": "^3.400.0",
    "socket.io": "^4.6.0"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@nestjs/schematics": "^10.0.0",
    "@nestjs/testing": "^10.0.0",
    "@types/bcryptjs": "^2.4.2",
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.2",
    "@types/multer": "^1.4.7",
    "@types/node": "^20.3.1",
    "@types/passport-jwt": "^3.0.9",
    "@types/passport-local": "^1.0.35",
    "@types/supertest": "^2.0.12",
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "eslint": "^8.42.0",
    "eslint-config-prettier": "^9.0.0",
    "eslint-plugin-prettier": "^5.0.0",
    "jest": "^29.5.0",
    "prettier": "^3.0.0",
    "source-map-support": "^0.5.21",
    "supertest": "^6.3.3",
    "ts-jest": "^29.1.0",
    "ts-loader": "^9.4.3",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.1.3"
  }
}
```

### 2. Main Application Entry Point

#### src/main.ts
```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as helmet from 'helmet';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  
  // Security
  app.use(helmet());
  app.enableCors({
    origin: configService.get('CORS_ORIGIN'),
    credentials: true,
  });
  
  // Global prefix
  app.setGlobalPrefix('api/v1');
  
  // Global pipes
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );
  
  // Global filters
  app.useGlobalFilters(new AllExceptionsFilter());
  
  // Global interceptors
  app.useGlobalInterceptors(new TransformInterceptor());
  
  // Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('Barter API')
    .setDescription('API for accommodation bartering system')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);
  
  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
  
  console.log(`Application is running on: ${await app.getUrl()}`);
}

bootstrap();
```

#### src/app.module.ts
```typescript
import { Module, CacheModule } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BullModule } from '@nestjs/bull';
import { ThrottlerModule } from '@nestjs/throttler';
import * as redisStore from 'cache-manager-redis-store';

import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PropertiesModule } from './properties/properties.module';
import { BartersModule } from './barters/barters.module';
import { VerificationModule } from './verification/verification.module';
import { MessagingModule } from './messaging/messaging.module';
import { PaymentsModule } from './payments/payments.module';
import { SearchModule } from './search/search.module';
import { NotificationModule } from './notification/notification.module';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    
    // Database
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: configService.get('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_NAME'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: configService.get('NODE_ENV') !== 'production',
        logging: configService.get('NODE_ENV') === 'development',
      }),
      inject: [ConfigService],
    }),
    
    // Cache
    CacheModule.registerAsync({
      isGlobal: true,
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        store: redisStore,
        host: configService.get('REDIS_HOST'),
        port: configService.get('REDIS_PORT'),
        ttl: 60,
      }),
      inject: [ConfigService],
    }),
    
    // Queue
    BullModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        redis: {
          host: configService.get('REDIS_HOST'),
          port: configService.get('REDIS_PORT'),
        },
      }),
      inject: [ConfigService],
    }),
    
    // Rate limiting
    ThrottlerModule.forRoot({
      ttl: 60,
      limit: 100,
    }),
    
    // Feature modules
    AuthModule,
    UsersModule,
    PropertiesModule,
    BartersModule,
    VerificationModule,
    MessagingModule,
    PaymentsModule,
    SearchModule,
    NotificationModule,
  ],
})
export class AppModule {}
```

### 3. Authentication Module

#### src/auth/auth.module.ts
```typescript
import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { UsersModule } from '../users/users.module';
import { LocalStrategy } from './strategies/local.strategy';
import { JwtStrategy } from './strategies/jwt.strategy';
import { RefreshTokenStrategy } from './strategies/refresh-token.strategy';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get('JWT_EXPIRATION'),
        },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, LocalStrategy, JwtStrategy, RefreshTokenStrategy],
  exports: [AuthService],
})
export class AuthModule {}
```

#### src/auth/auth.service.ts
```typescript
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { UsersService } from '../users/users.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}
  
  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.usersService.findByEmail(email);
    
    if (user && await bcrypt.compare(password, user.password)) {
      return user;
    }
    
    return null;
  }
  
  async login(user: User) {
    const payload = { email: user.email, sub: user.id };
    
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION'),
    });
    
    await this.usersService.updateRefreshToken(user.id, refreshToken);
    
    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        isVerified: user.isVerified,
      },
      tokens: {
        accessToken,
        refreshToken,
      },
    };
  }
  
  async register(registerDto: RegisterDto) {
    const existingUser = await this.usersService.findByEmail(registerDto.email);
    
    if (existingUser) {
      throw new ConflictException('Email already exists');
    }
    
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);
    
    const user = await this.usersService.create({
      ...registerDto,
      password: hashedPassword,
    });
    
    return this.login(user);
  }
  
  async refreshTokens(userId: string, refreshToken: string) {
    const user = await this.usersService.findOne(userId);
    
    if (!user || !user.refreshToken) {
      throw new UnauthorizedException('Invalid refresh token');
    }
    
    const refreshTokenMatches = await bcrypt.compare(
      refreshToken,
      user.refreshToken,
    );
    
    if (!refreshTokenMatches) {
      throw new UnauthorizedException('Invalid refresh token');
    }
    
    const payload = { email: user.email, sub: user.id };
    
    const newAccessToken = this.jwtService.sign(payload);
    const newRefreshToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRATION'),
    });
    
    await this.usersService.updateRefreshToken(user.id, newRefreshToken);
    
    return {
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    };
  }
  
  async logout(userId: string) {
    await this.usersService.updateRefreshToken(userId, null);
  }
}
```

#### src/auth/auth.controller.ts
```typescript
import { Controller, Post, Body, UseGuards, Req, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RefreshTokenGuard } from './guards/refresh-token.guard';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}
  
  @Post('register')
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User successfully registered' })
  @ApiResponse({ status: 409, description: 'Email already exists' })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }
  
  @UseGuards(LocalAuthGuard)
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Login user' })
  @ApiResponse({ status: 200, description: 'User successfully logged in' })
  @ApiResponse({ status: 401, description: 'Invalid credentials' })
  async login(@Body() loginDto: LoginDto, @CurrentUser() user: User) {
    return this.authService.login(user);
  }
  
  @UseGuards(RefreshTokenGuard)
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token' })
  async refresh(@CurrentUser() user: User, @Req() req: any) {
    const refreshToken = req.get('Authorization').replace('Bearer', '').trim();
    return this.authService.refreshTokens(user.id, refreshToken);
  }
  
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout user' })
  async logout(@CurrentUser() user: User) {
    return this.authService.logout(user.id);
  }
}
```

### 4. Properties Module

#### src/properties/entities/property.entity.ts
```typescript
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { PropertyImage } from './property-image.entity';
import { PropertyAvailability } from './property-availability.entity';
import { VerificationRequest } from '../../verification/entities/verification-request.entity';
import { BarterRequest } from '../../barters/entities/barter-request.entity';

export enum PropertyType {
  APARTMENT = 'apartment',
  HOUSE = 'house',
  VILLA = 'villa',
  CONDO = 'condo',
  CABIN = 'cabin',
  OTHER = 'other',
}

export enum VerificationStatus {
  UNVERIFIED = 'unverified',
  PENDING = 'pending',
  VERIFIED = 'verified',
  REJECTED = 'rejected',
}

@Entity('properties')
export class Property {
  @PrimaryGeneratedColumn('uuid')
  id: string;
  
  @ManyToOne(() => User, user => user.properties)
  @JoinColumn({ name: 'owner_id' })
  owner: User;
  
  @Column({ name: 'owner_id' })
  ownerId: string;
  
  @Column()
  title: string;
  
  @Column('text')
  description: string;
  
  @Column()
  address: string;
  
  @Column()
  city: string;
  
  @Column()
  country: string;
  
  @Column('decimal', { precision: 10, scale: 8 })
  latitude: number;
  
  @Column('decimal', { precision: 11, scale: 8 })
  longitude: number;
  
  @Column({
    type: 'enum',
    enum: PropertyType,
    default: PropertyType.OTHER,
  })
  propertyType: PropertyType;
  
  @Column({ name: 'max_guests' })
  maxGuests: number;
  
  @Column()
  bedrooms: number;
  
  @Column()
  bathrooms: number;
  
  @Column('simple-array')
  amenities: string[];
  
  @Column({
    type: 'enum',
    enum: VerificationStatus,
    default: VerificationStatus.UNVERIFIED,
  })
  verificationStatus: VerificationStatus;
  
  @OneToMany(() => PropertyImage, image => image.property)
  images: PropertyImage[];
  
  @OneToMany(() => PropertyAvailability, availability => availability.property)
  availability: PropertyAvailability[];
  
  @OneToMany(() => VerificationRequest, request => request.property)
  verificationRequests: VerificationRequest[];
  
  @OneToMany(() => BarterRequest, barter => barter.offerProperty)
  offeredInBarters: BarterRequest[];
  
  @OneToMany(() => BarterRequest, barter => barter.targetProperty)
  targetedInBarters: BarterRequest[];
  
  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
  
  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
```

#### src/properties/properties.service.ts
```typescript
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, ILike } from 'typeorm';
import { Property } from './entities/property.entity';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { SearchPropertyDto } from './dto/search-property.dto';
import { PropertyImage } from './entities/property-image.entity';
import { PropertyAvailability } from './entities/property-availability.entity';
import { S3Service } from '../common/services/s3.service';
import { ElasticsearchService } from '../search/elasticsearch.service';

@Injectable()
export class PropertiesService {
  constructor(
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
    @InjectRepository(PropertyImage)
    private readonly imageRepository: Repository<PropertyImage>,
    @InjectRepository(PropertyAvailability)
    private readonly availabilityRepository: Repository<PropertyAvailability>,
    private readonly s3Service: S3Service,
    private readonly elasticsearchService: ElasticsearchService,
  ) {}
  
  async create(createPropertyDto: CreatePropertyDto, userId: string): Promise<Property> {
    const property = this.propertyRepository.create({
      ...createPropertyDto,
      ownerId: userId,
    });
    
    const savedProperty = await this.propertyRepository.save(property);
    
    // Index in Elasticsearch for search
    await this.elasticsearchService.indexProperty(savedProperty);
    
    return savedProperty;
  }
  
  async findAll(searchDto: SearchPropertyDto): Promise<Property[]> {
    const query = this.propertyRepository.createQueryBuilder('property')
      .leftJoinAndSelect('property.images', 'images')
      .leftJoinAndSelect('property.owner', 'owner');
    
    if (searchDto.city) {
      query.andWhere('property.city ILIKE :city', { city: `%${searchDto.city}%` });
    }
    
    if (searchDto.country) {
      query.andWhere('property.country = :country', { country: searchDto.country });
    }
    
    if (searchDto.propertyType) {
      query.andWhere('property.propertyType = :type', { type: searchDto.propertyType });
    }
    
    if (searchDto.minGuests) {
      query.andWhere('property.maxGuests >= :minGuests', { minGuests: searchDto.minGuests });
    }
    
    if (searchDto.bedrooms) {
      query.andWhere('property.bedrooms >= :bedrooms', { bedrooms: searchDto.bedrooms });
    }
    
    if (searchDto.verifiedOnly) {
      query.andWhere('property.verificationStatus = :status', { status: 'verified' });
    }
    
    // Check availability
    if (searchDto.startDate && searchDto.endDate) {
      query.innerJoin(
        'property.availability',
        'availability',
        'availability.startDate <= :startDate AND availability.endDate >= :endDate AND availability.isAvailable = true',
        { startDate: searchDto.startDate, endDate: searchDto.endDate },
      );
    }
    
    query.orderBy('property.createdAt', 'DESC');
    
    if (searchDto.limit) {
      query.limit(searchDto.limit);
    }
    
    if (searchDto.offset) {
      query.offset(searchDto.offset);
    }
    
    return query.getMany();
  }
  
  async findOne(id: string): Promise<Property> {
    const property = await this.propertyRepository.findOne({
      where: { id },
      relations: ['owner', 'images', 'availability'],
    });
    
    if (!property) {
      throw new NotFoundException('Property not found');
    }
    
    return property;
  }
  
  async update(
    id: string,
    updatePropertyDto: UpdatePropertyDto,
    userId: string,
  ): Promise<Property> {
    const property = await this.findOne(id);
    
    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only update your own properties');
    }
    
    Object.assign(property, updatePropertyDto);
    
    const updatedProperty = await this.propertyRepository.save(property);
    
    // Update Elasticsearch index
    await this.elasticsearchService.updateProperty(updatedProperty);
    
    return updatedProperty;
  }
  
  async remove(id: string, userId: string): Promise<void> {
    const property = await this.findOne(id);
    
    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only delete your own properties');
    }
    
    // Delete images from S3
    for (const image of property.images) {
      await this.s3Service.deleteFile(image.imageKey);
    }
    
    // Remove from Elasticsearch
    await this.elasticsearchService.deleteProperty(id);
    
    await this.propertyRepository.remove(property);
  }
  
  async uploadImages(
    propertyId: string,
    files: Express.Multer.File[],
    userId: string,
  ): Promise<PropertyImage[]> {
    const property = await this.findOne(propertyId);
    
    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only upload images to your own properties');
    }
    
    const images: PropertyImage[] = [];
    
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const key = `properties/${propertyId}/${Date.now()}-${file.originalname}`;
      
      const uploadResult = await this.s3Service.uploadFile(file, key);
      
      const image = this.imageRepository.create({
        propertyId,
        imageUrl: uploadResult.url,
        imageKey: uploadResult.key,
        isPrimary: i === 0 && property.images.length === 0,
        orderIndex: property.images.length + i,
      });
      
      const savedImage = await this.imageRepository.save(image);
      images.push(savedImage);
    }
    
    return images;
  }
  
  async updateAvailability(
    propertyId: string,
    availability: { startDate: Date; endDate: Date; isAvailable: boolean }[],
    userId: string,
  ): Promise<PropertyAvailability[]> {
    const property = await this.findOne(propertyId);
    
    if (property.ownerId !== userId) {
      throw new ForbiddenException('You can only update availability for your own properties');
    }
    
    // Remove old availability
    await this.availabilityRepository.delete({ propertyId });
    
    // Add new availability
    const availabilityEntries = availability.map(entry =>
      this.availabilityRepository.create({
        propertyId,
        ...entry,
      }),
    );
    
    return this.availabilityRepository.save(availabilityEntries);
  }
  
  async searchNearby(
    latitude: number,
    longitude: number,
    radiusKm: number = 50,
  ): Promise<Property[]> {
    // Use Elasticsearch geo search
    const results = await this.elasticsearchService.searchNearby(
      latitude,
      longitude,
      radiusKm,
    );
    
    const propertyIds = results.map(r => r.id);
    
    if (propertyIds.length === 0) {
      return [];
    }
    
    return this.propertyRepository.findByIds(propertyIds, {
      relations: ['images', 'owner'],
    });
  }
}
```

### 5. Barter/Matching Module

#### src/barters/barters.service.ts
```typescript
import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BarterRequest, BarterStatus } from './entities/barter-request.entity';
import { CreateBarterDto } from './dto/create-barter.dto';
import { PropertiesService } from '../properties/properties.service';
import { NotificationService } from '../notification/notification.service';
import { MessagingGateway } from '../messaging/messaging.gateway';

@Injectable()
export class BartersService {
  constructor(
    @InjectRepository(BarterRequest)
    private readonly barterRepository: Repository<BarterRequest>,
    private readonly propertiesService: PropertiesService,
    private readonly notificationService: NotificationService,
    private readonly messagingGateway: MessagingGateway,
  ) {}
  
  async createBarterRequest(
    createBarterDto: CreateBarterDto,
    requesterId: string,
  ): Promise<BarterRequest> {
    // Validate properties exist
    const offerProperty = await this.propertiesService.findOne(
      createBarterDto.offerPropertyId,
    );
    const targetProperty = await this.propertiesService.findOne(
      createBarterDto.targetPropertyId,
    );
    
    // Check ownership
    if (offerProperty.ownerId !== requesterId) {
      throw new ForbiddenException('You can only offer your own properties');
    }
    
    if (targetProperty.ownerId === requesterId) {
      throw new BadRequestException('You cannot barter with your own property');
    }
    
    // Check for existing pending requests
    const existingRequest = await this.barterRepository.findOne({
      where: {
        requesterId,
        offerPropertyId: createBarterDto.offerPropertyId,
        targetPropertyId: createBarterDto.targetPropertyId,
        status: BarterStatus.PENDING,
      },
    });
    
    if (existingRequest) {
      throw new BadRequestException('You already have a pending request for this property');
    }
    
    // Check availability
    const isOfferAvailable = await this.checkAvailability(
      createBarterDto.offerPropertyId,
      createBarterDto.startDate,
      createBarterDto.endDate,
    );
    
    const isTargetAvailable = await this.checkAvailability(
      createBarterDto.targetPropertyId,
      createBarterDto.startDate,
      createBarterDto.endDate,
    );
    
    if (!isOfferAvailable || !isTargetAvailable) {
      throw new BadRequestException('One or both properties are not available for the selected dates');
    }
    
    // Create barter request
    const barterRequest = this.barterRepository.create({
      ...createBarterDto,
      requesterId,
      status: BarterStatus.PENDING,
    });
    
    const savedRequest = await this.barterRepository.save(barterRequest);
    
    // Send notification to target property owner
    await this.notificationService.sendBarterRequestNotification(
      targetProperty.ownerId,
      savedRequest,
    );
    
    // Emit real-time update
    this.messagingGateway.server
      .to(`user-${targetProperty.ownerId}`)
      .emit('new-barter-request', savedRequest);
    
    return savedRequest;
  }
  
  async findUserRequests(userId: string): Promise<BarterRequest[]> {
    return this.barterRepository.find({
      where: { requesterId: userId },
      relations: ['offerProperty', 'targetProperty'],
      order: { createdAt: 'DESC' },
    });
  }
  
  async findReceivedRequests(userId: string): Promise<BarterRequest[]> {
    const userProperties = await this.propertiesService.findByOwner(userId);
    const propertyIds = userProperties.map(p => p.id);
    
    if (propertyIds.length === 0) {
      return [];
    }
    
    return this.barterRepository
      .createQueryBuilder('barter')
      .leftJoinAndSelect('barter.offerProperty', 'offerProperty')
      .leftJoinAndSelect('barter.targetProperty', 'targetProperty')
      .leftJoinAndSelect('barter.requester', 'requester')
      .where('barter.targetPropertyId IN (:...propertyIds)', { propertyIds })
      .orderBy('barter.createdAt', 'DESC')
      .getMany();
  }
  
  async acceptBarter(
    barterId: string,
    userId: string,
  ): Promise<BarterRequest> {
    const barter = await this.findOne(barterId);
    
    // Check ownership of target property
    const targetProperty = await this.propertiesService.findOne(
      barter.targetPropertyId,
    );
    
    if (targetProperty.ownerId !== userId) {
      throw new ForbiddenException('You can only accept barters for your own properties');
    }
    
    if (barter.status !== BarterStatus.PENDING) {
      throw new BadRequestException('This barter request is no longer pending');
    }
    
    // Check availability again
    const isOfferAvailable = await this.checkAvailability(
      barter.offerPropertyId,
      barter.startDate,
      barter.endDate,
    );
    
    const isTargetAvailable = await this.checkAvailability(
      barter.targetPropertyId,
      barter.startDate,
      barter.endDate,
    );
    
    if (!isOfferAvailable || !isTargetAvailable) {
      throw new BadRequestException('Properties are no longer available for the selected dates');
    }
    
    // Update status
    barter.status = BarterStatus.ACCEPTED;
    const updatedBarter = await this.barterRepository.save(barter);
    
    // Block dates for both properties
    await this.blockDates(barter.offerPropertyId, barter.startDate, barter.endDate);
    await this.blockDates(barter.targetPropertyId, barter.startDate, barter.endDate);
    
    // Reject other pending requests for the same dates
    await this.rejectConflictingRequests(barter);
    
    // Send notifications
    await this.notificationService.sendBarterAcceptedNotification(
      barter.requesterId,
      updatedBarter,
    );
    
    // Emit real-time update
    this.messagingGateway.server
      .to(`user-${barter.requesterId}`)
      .emit('barter-accepted', updatedBarter);
    
    return updatedBarter;
  }
  
  async rejectBarter(
    barterId: string,
    userId: string,
    reason?: string,
  ): Promise<BarterRequest> {
    const barter = await this.findOne(barterId);
    
    // Check ownership
    const targetProperty = await this.propertiesService.findOne(
      barter.targetPropertyId,
    );
    
    if (targetProperty.ownerId !== userId) {
      throw new ForbiddenException('You can only reject barters for your own properties');
    }
    
    if (barter.status !== BarterStatus.PENDING) {
      throw new BadRequestException('This barter request is no longer pending');
    }
    
    barter.status = BarterStatus.REJECTED;
    barter.rejectionReason = reason;
    
    const updatedBarter = await this.barterRepository.save(barter);
    
    // Send notification
    await this.notificationService.sendBarterRejectedNotification(
      barter.requesterId,
      updatedBarter,
    );
    
    return updatedBarter;
  }
  
  async cancelBarter(barterId: string, userId: string): Promise<BarterRequest> {
    const barter = await this.findOne(barterId);
    
    if (barter.requesterId !== userId) {
      throw new ForbiddenException('You can only cancel your own barter requests');
    }
    
    if (barter.status !== BarterStatus.PENDING) {
      throw new BadRequestException('Only pending requests can be cancelled');
    }
    
    barter.status = BarterStatus.CANCELLED;
    
    return this.barterRepository.save(barter);
  }
  
  private async findOne(id: string): Promise<BarterRequest> {
    const barter = await this.barterRepository.findOne({
      where: { id },
      relations: ['offerProperty', 'targetProperty', 'requester'],
    });
    
    if (!barter) {
      throw new NotFoundException('Barter request not found');
    }
    
    return barter;
  }
  
  private async checkAvailability(
    propertyId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<boolean> {
    // Implementation to check property availability
    return true; // Placeholder
  }
  
  private async blockDates(
    propertyId: string,
    startDate: Date,
    endDate: Date,
  ): Promise<void> {
    // Implementation to block dates for property
  }
  
  private async rejectConflictingRequests(
    acceptedBarter: BarterRequest,
  ): Promise<void> {
    // Find and reject other pending requests that conflict with accepted dates
  }
}
```

### 6. WebSocket Messaging

#### src/messaging/messaging.gateway.ts
```typescript
import {
  WebSocketGateway,
  SubscribeMessage,
  MessageBody,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { UseGuards } from '@nestjs/common';
import { WsJwtGuard } from '../auth/guards/ws-jwt.guard';
import { MessagingService } from './messaging.service';
import { SendMessageDto } from './dto/send-message.dto';

@WebSocketGateway({
  cors: {
    origin: process.env.CLIENT_URL,
    credentials: true,
  },
  namespace: 'messages',
})
@UseGuards(WsJwtGuard)
export class MessagingGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;
  
  private activeUsers = new Map<string, string>();
  
  constructor(private readonly messagingService: MessagingService) {}
  
  async handleConnection(client: Socket) {
    const userId = client.data.userId;
    if (userId) {
      this.activeUsers.set(client.id, userId);
      client.join(`user-${userId}`);
      
      // Load user's conversations
      const conversations = await this.messagingService.getUserConversations(userId);
      conversations.forEach(conv => {
        client.join(`barter-${conv.barterId}`);
      });
      
      console.log(`User ${userId} connected`);
    }
  }
  
  handleDisconnect(client: Socket) {
    const userId = this.activeUsers.get(client.id);
    if (userId) {
      this.activeUsers.delete(client.id);
      console.log(`User ${userId} disconnected`);
    }
  }
  
  @SubscribeMessage('send-message')
  async handleMessage(
    @MessageBody() sendMessageDto: SendMessageDto,
    @ConnectedSocket() client: Socket,
  ) {
    const userId = client.data.userId;
    
    // Validate user is part of this barter
    const hasAccess = await this.messagingService.userHasAccess(
      userId,
      sendMessageDto.barterId,
    );
    
    if (!hasAccess) {
      client.emit('error', { message: 'Unauthorized to send message to this conversation' });
      return;
    }
    
    // Save message
    const message = await this.messagingService.createMessage({
      ...sendMessageDto,
      senderId: userId,
    });
    
    // Emit to all users in the conversation
    this.server
      .to(`barter-${sendMessageDto.barterId}`)
      .emit('new-message', message);
    
    return message;
  }
  
  @SubscribeMessage('typing')
  handleTyping(
    @MessageBody() data: { barterId: string; isTyping: boolean },
    @ConnectedSocket() client: Socket,
  ) {
    const userId = client.data.userId;
    
    client.to(`barter-${data.barterId}`).emit('user-typing', {
      userId,
      isTyping: data.isTyping,
    });
  }
  
  @SubscribeMessage('mark-read')
  async handleMarkRead(
    @MessageBody() data: { barterId: string; messageId: string },
    @ConnectedSocket() client: Socket,
  ) {
    const userId = client.data.userId;
    
    await this.messagingService.markAsRead(data.messageId, userId);
    
    client.to(`barter-${data.barterId}`).emit('message-read', {
      messageId: data.messageId,
      readBy: userId,
    });
  }
}
```

### 7. Environment Configuration

#### .env.example
```env
# Application
NODE_ENV=development
PORT=3000
CLIENT_URL=http://localhost:3001
CORS_ORIGIN=http://localhost:3001

# Database
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=yourpassword
DB_NAME=barterdb

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRATION=15m
JWT_REFRESH_SECRET=your-super-secret-refresh-key
JWT_REFRESH_EXPIRATION=7d

# AWS S3
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET=barter-app-images

# Stripe
STRIPE_SECRET_KEY=sk_test_your_stripe_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Email (SendGrid)
SENDGRID_API_KEY=your-sendgrid-api-key
EMAIL_FROM=noreply@barterapp.com

# Elasticsearch
ELASTICSEARCH_NODE=http://localhost:9200
ELASTICSEARCH_USERNAME=elastic
ELASTICSEARCH_PASSWORD=yourpassword

# Google Maps
GOOGLE_MAPS_API_KEY=your-google-maps-key

# Twilio (SMS)
TWILIO_ACCOUNT_SID=your-account-sid
TWILIO_AUTH_TOKEN=your-auth-token
TWILIO_PHONE_NUMBER=+1234567890
```

### 8. Docker Configuration

#### docker-compose.yml
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: barterdb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - '5432:5432'
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - '6379:6379'
    volumes:
      - redis_data:/data
  
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.9.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - '9200:9200'
    volumes:
      - es_data:/usr/share/elasticsearch/data
  
  api:
    build: .
    ports:
      - '3000:3000'
    environment:
      - NODE_ENV=development
    depends_on:
      - postgres
      - redis
      - elasticsearch
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run start:dev

volumes:
  postgres_data:
  redis_data:
  es_data:
```

#### Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["node", "dist/main"]
```

This comprehensive backend implementation provides all the necessary APIs and services for your accommodation bartering system!

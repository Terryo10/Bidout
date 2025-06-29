# Bidout - Construction Project Bidding Platform

A comprehensive Flutter application for connecting clients with contractors for construction projects, featuring a robust bidding system.

## New Features Added: Bidding System

### Overview
The bidding functionality allows contractors to submit bids on client projects and enables clients to view and manage received bids.

### Backend Implementation (Laravel)

#### New API Endpoints
- `GET /api/contractor/bids` - Get contractor's own bids with filtering and pagination
- `POST /api/projects/{project}/bids` - Submit a new bid
- `GET /api/projects/{project}/bids` - Get all bids for a project (client view)
- `PUT /api/projects/{project}/bids/{bid}` - Update a bid
- `DELETE /api/projects/{project}/bids/{bid}` - Withdraw/delete a bid

#### Database Schema
The `Bid` model includes:
- `project_id` - Foreign key to projects table
- `contractor_id` - Foreign key to users table
- `amount` - Bid amount (decimal)
- `description` - Proposal description
- `timeline` - Timeline in days (integer)
- `status` - 'pending', 'accepted', 'rejected'
- `proposed_start_date` - Proposed start date
- `proposed_end_date` - Proposed end date
- `notes` - Additional notes

### Flutter Implementation

#### Models
- **BidModel** - Main bid data model with JSON serialization
- **BidRequestModel** - Request model for creating/updating bids

#### BLoC Architecture

##### BidsBloc
- Manages all bid-related state
- Handles contractor and project bid loading
- Supports pagination and filtering
- Manages CRUD operations for bids

##### Events
- `ContractorBidsLoadRequested` - Load contractor's bids
- `ProjectBidsLoadRequested` - Load bids for a project
- `BidCreateRequested` - Create a new bid
- `BidUpdateRequested` - Update existing bid
- `BidDeleteRequested` - Delete/withdraw bid

##### States
- `ContractorBidsLoaded` - Contractor's bids with pagination
- `ProjectBidsLoaded` - Project bids for clients
- `BidCreated` - Successful bid creation
- `BidUpdated` - Successful bid update
- `BidDeleted` - Successful bid deletion

#### Repository Pattern
- **BidsRepository** - Business logic layer
- **BidsProvider** - API communication layer
- Follows existing app patterns for consistency

#### UI Components

##### Contractor Features
1. **ContractorBidsPage** - Main page showing all contractor's bids
   - Filter by status (pending, accepted, rejected)
   - Search by project title
   - Stats header showing bid counts
   - Pull-to-refresh and infinite scroll

2. **CreateBidPage** - Form for submitting new bids
   - Project information display
   - Bid amount and timeline inputs
   - Proposal description (minimum 50 characters)
   - Optional start/end dates
   - Form validation

3. **BidCard** - Reusable bid display component
   - Status badges with color coding
   - Project information
   - Bid details (amount, timeline)
   - Action menu (edit/withdraw for pending bids)

4. **BidFilterSheet** - Bottom sheet for filtering bids
   - Status filter chips
   - Search functionality
   - Clear filters option

##### Client Features
1. **ProjectBidsPage** - View all bids for a project
   - Project budget display
   - Bid statistics (total, lowest, average)
   - Contractor information and ratings
   - Bid acceptance/rejection (coming soon)

#### Key Features

##### For Contractors
- View all submitted bids in one place
- Filter bids by status and search by project
- Submit detailed proposals with timeline
- Edit pending bids
- Withdraw bids before acceptance
- Visual status indicators

##### For Clients
- View all received bids for projects
- Compare bid amounts and timelines
- See contractor profiles and ratings
- Track bid statistics
- Future: Accept/reject bids

#### Integration Points

##### App Structure
- Added BidsBloc to MultiBlocProvider in app_blocs.dart
- Added BidsRepository to app_repositories.dart
- Follows existing navigation patterns

##### Navigation
- Navigate from project listing to CreateBidPage
- Navigate from contractor dashboard to ContractorBidsPage
- Navigate from project details to ProjectBidsPage

#### Design Patterns

##### Consistency
- Follows existing app design language
- Uses AppColors for consistent theming
- Matches existing card layouts and animations
- Responsive design for different screen sizes

##### User Experience
- Loading states with shimmer effects
- Error handling with retry options
- Pull-to-refresh functionality
- Infinite scroll pagination
- Confirmation dialogs for destructive actions

### Technical Implementation

#### Error Handling
- API error models for structured error responses
- Network connectivity checks
- Graceful fallbacks for offline scenarios
- User-friendly error messages

#### Performance
- Pagination for large bid lists
- Efficient state management with BLoC
- Optimized list rendering with ListView.builder
- Image caching for contractor avatars

#### Security
- JWT token authentication
- Role-based access control
- Input validation and sanitization
- Protection against unauthorized bid access

### Future Enhancements

1. **Real-time Updates** - WebSocket integration for live bid updates
2. **Bid Notifications** - Push notifications for new bids and status changes
3. **Advanced Filtering** - Date ranges, price ranges, contractor ratings
4. **Bid Comparisons** - Side-by-side bid comparison tool
5. **Contract Management** - Integration with contract generation
6. **Payment Integration** - Connect with payment processing
7. **Rating System** - Post-project rating and review system
8. **Analytics** - Bid success rates and market insights

### Installation & Setup

1. Backend setup (Laravel):
   ```bash
   php artisan migrate
   php artisan db:seed --class=BidPackageSeeder
   ```

2. Flutter dependencies:
   ```yaml
   dependencies:
     flutter_bloc: ^8.1.3
     equatable: ^2.0.5
     http: ^1.1.0
     intl: ^0.18.1
   ```

3. Add to app_blocs.dart:
   ```dart
   BlocProvider<BidsBloc>(
     create: (context) => BidsBloc(
       bidsRepository: context.read<BidsRepository>(),
     ),
   ),
   ```

### Testing

- Unit tests for BidModel serialization
- Widget tests for bid cards and forms
- Integration tests for bid submission flow
- API endpoint testing with Postman collection

### Documentation

- API documentation with request/response examples
- Widget documentation with usage examples
- State management flow diagrams
- Database relationship diagrams

This bidding system provides a solid foundation for the core functionality of the Bidout platform, enabling efficient project-contractor matching through a competitive bidding process.

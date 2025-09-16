# Task Assignment and Management App - Backend

This is the backend API for the Task Assignment and Management App built with Node.js, Express, and MongoDB.

## Features

- **User Management**: Registration, login, profile management with role-based access
- **Task Management**: Create, assign, update, and track tasks
- **Team Management**: Create and manage teams with members
- **Notice System**: Post and manage company notices
- **Task Assignment Approval**: Request and approve task assignments
- **Role-based Permissions**: Different access levels for CEO, Project Manager, HR, and Team Members

## Tech Stack

- **Node.js** - Runtime environment
- **Express.js** - Web framework
- **MongoDB** - Database
- **Mongoose** - ODM for MongoDB
- **JWT** - Authentication
- **bcryptjs** - Password hashing
- **CORS** - Cross-origin resource sharing

## Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the backend directory with the following variables:
```env
# Database
MONGODB_URI=mongodb://localhost:27017/task_management

# JWT
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRE=7d
JWT_REFRESH_SECRET=your-super-secret-refresh-key-here
JWT_REFRESH_EXPIRE=30d

# Server
PORT=5000
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000
```

3. Start the server:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/users/register` - Register a new user
- `POST /api/users/login` - Login user
- `GET /api/users/profile` - Get current user profile
- `PUT /api/users/profile` - Update user profile

### Users (Admin only)
- `GET /api/users/all` - Get all users
- `PUT /api/users/:userId` - Update user
- `DELETE /api/users/:userId` - Delete user

### Tasks
- `POST /api/tasks` - Create a new task
- `GET /api/tasks` - Get all tasks
- `GET /api/tasks/:taskId` - Get task by ID
- `PUT /api/tasks/:taskId` - Update task
- `DELETE /api/tasks/:taskId` - Delete task
- `GET /api/tasks/user/:userId` - Get user's tasks

### Teams (CEO/Project Manager only)
- `POST /api/teams` - Create a new team
- `GET /api/teams` - Get all teams
- `GET /api/teams/:teamId` - Get team by ID
- `PUT /api/teams/:teamId` - Update team
- `DELETE /api/teams/:teamId` - Delete team
- `POST /api/teams/:teamId/members` - Add member to team
- `DELETE /api/teams/:teamId/members/:userId` - Remove member from team

### Notices
- `POST /api/notices` - Create a new notice (HR/CEO only)
- `GET /api/notices` - Get all notices
- `GET /api/notices/user` - Get notices for current user
- `GET /api/notices/:noticeId` - Get notice by ID
- `PUT /api/notices/:noticeId` - Update notice
- `DELETE /api/notices/:noticeId` - Delete notice

### Task Assignments
- `POST /api/task-assignments` - Create task assignment request
- `GET /api/task-assignments` - Get all task assignments
- `GET /api/task-assignments/:assignmentId` - Get assignment by ID
- `PUT /api/task-assignments/:assignmentId` - Update assignment
- `DELETE /api/task-assignments/:assignmentId` - Delete assignment
- `PUT /api/task-assignments/:assignmentId/approve` - Approve assignment (CEO/PM only)
- `PUT /api/task-assignments/:assignmentId/reject` - Reject assignment (CEO/PM only)

## User Roles and Permissions

### CEO
- Full access to all features
- Can manage users, teams, tasks, and notices
- Can approve/reject task assignments

### Project Manager
- Can manage teams and tasks
- Can approve/reject task assignments
- Can view all tasks

### HR
- Can post notices
- Can assign tasks with approval
- Limited access to other features

### Team Member
- Can view assigned tasks
- Can assign tasks with approval
- Can request task assignments

## Database Models

### User
- Basic user information with role-based permissions
- Password hashing and JWT authentication
- Team association

### Task
- Task details with status, priority, and assignment
- Due dates and time tracking
- Tags and attachments support

### Team
- Team information with leader and members
- Member management functionality

### Notice
- Company notices with targeting by role
- Scheduling and expiry support
- Rich content with attachments

### TaskAssignment
- Task assignment requests and approvals
- Status tracking and rejection reasons
- Approval workflow

## Error Handling

The API includes comprehensive error handling for:
- Validation errors
- Authentication errors
- Authorization errors
- Database errors
- JWT token errors

## Security Features

- Password hashing with bcrypt
- JWT token authentication
- Role-based authorization
- CORS configuration
- Input validation and sanitization

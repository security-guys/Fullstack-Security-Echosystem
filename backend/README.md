This translation covers the entire content of your `README.md` for the **Node.js Express Learning Process**, maintaining the exact structure, code blocks, and formatting as requested.

---

# Node Express Learning Process

## Step 1: Understanding Basic Structure

- Express.js Application Setup
  - Middleware configuration (cors, express.json)
  - Route configuration
  - Error handling
- Environment Variable Setup (.env)
- Server Execution Setup

## Step 2: Database

- MongoDB Connection Setup
  - Connection using Mongoose
  - Connection string management via environment variables
- Model Definition
  - User Model
  - Post Model

## Step 3: Authentication System

- JWT-based Authentication
- User Management API
  - Registration
  - Login
  - User Info Lookup/Modification

## Step 4: API Endpoints

- RESTful API Design
  - /api/users endpoints
  - /api/posts endpoints
- Request/Response Processing
  - JSON data processing
  - Error response processing

## Step 5: Middleware

- CORS Configuration
  - Allowed origin management
  - HTTP method restrictions
- Logging Middleware
- Error Handling Middleware

## Step 6: Security

- CORS Security Settings
- Input Data Validation
- Error Handling and Logging

## Step 7: Testing and Deployment

- API Testing
- Server Status Monitoring
- Deployment Configuration

---

## Step 1: Understanding Basic Structure

### 1. Express.js Application Setup

#### A. Middleware Configuration

1. **CORS Configuration**

```javascript
const corsOptions = {
  origin: function (origin, callback) {
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
};
```

- Allow requests only from specific domains
- Configure allowed HTTP methods
- Allow authentication headers

2. **Basic Middleware**

```javascript
app.use(express.json()); // Parse JSON request bodies
```

3. **Logging Middleware**

```javascript
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});
```

#### B. Route Configuration

```javascript
app.use("/api/users", userRoutes);
app.use("/api/posts", postRoutes);
```

- Use modularized routes
- API versioning (/api prefix)

#### C. Error Handling

```javascript
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something went wrong!" });
});
```

### 2. Environment Variable Setup

Manage environment variables using a `.env` file:

- `MONGODB_URI`: MongoDB connection string
- `PORT`: Server port
- `FRONTEND_URL`: Frontend URL

### 3. Server Execution Setup

```javascript
const PORT = process.env.PORT || 8080;
const HOST = "0.0.0.0";

app.listen(PORT, HOST, () => {
  console.log(`Server is running on http://${HOST}:${PORT}`);
});
```

Are there any parts you would like to look into more deeply? For example:

1. Route structure and API endpoints
2. How middleware operates
3. Error handling methods
4. How to set up environment variables

### Adding CORS IPs

Currently, the `allowedOrigins` array permits only the following two addresses:

```javascript
const allowedOrigins = ["http://localhost:3000", "http://192.168.219.120:3000"];
```

If the frontend IP changes, you must add the new address to this array. For example, if the frontend runs on `192.168.1.100:3000`:

```javascript
const allowedOrigins = [
  "http://localhost:3000",
  "http://192.168.219.120:3000",
  "http://192.168.1.100:3000", // Add new IP
];
```

Failing to do this may cause CORS errors. You will see errors like this in the browser developer tools console:

```
Access to fetch at 'http://your-backend-url' from origin 'http://new-frontend-ip:3000' has been blocked by CORS policy
```

## How JWT Tokens Work

Yes, I will explain the entire JWT process in great detail with examples.

### 1. Token Creation Process

```javascript
// 1. User Info
const user = {
  _id: "123456",
  username: "john_doe",
};

// 2. Generate JWT Token
const token = jwt.sign(
  { userId: user._id }, // Payload
  "mysecret123", // JWT_SECRET
  { expiresIn: "7d" }, // Options
);
```

What actually happens during this process:

1. **Header Creation**:

```javascript
const header = {
  alg: "HS256", // Hash algorithm
  typ: "JWT", // Token type
};
// Base64 encoded
// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
```

2. **Payload Creation**:

```javascript
const payload = {
  userId: "123456",
  iat: 1516239022, // Issued at
  exp: 1516843822, // Expiration (7 days later)
};
// Base64 encoded
// eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE1MTYyMzkwMjJ9
```

3. **Signature Creation**:

```javascript
// Join header and payload with a dot (.)
const data =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE1MTYyMzkwMjJ9";

// Create HMAC SHA-256 hash using JWT_SECRET
const signature = HMACSHA256(data, "mysecret123");
// Result: "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
```

4. **Final Token**:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

### 2. Token Verification Process

```javascript
// 1. Client sends the token
const token =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE1MTYyMzkwMjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

// 2. Server verifies the token
try {
  const decoded = jwt.verify(token, "mysecret123");
  console.log(decoded);
  // Output: { userId: "123456", iat: 1516239022, exp: 1516843822 }
} catch (error) {
  console.log("Token is invalid");
}
```

What happens during verification:

1. **Token Splitting**:

```
header = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
payload = "eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE1MTYyMzkwMjJ9"
signature = "SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
```

2. **Signature Verification**:

```javascript
// 1. Re-hash the header and payload
const data =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE1MTYyMzkwMjJ9";
const newSignature = HMACSHA256(data, "mysecret123");

// 2. Compare the newly created signature with the token's signature
if (newSignature === signature) {
  // If signatures match, decode the payload
  const decodedPayload = base64Decode(payload);
  // { userId: "123456", iat: 1516239022, exp: 1516843822 }
} else {
  // If signatures don't match, the token has been tampered with
  throw new Error("Invalid token");
}
```

### 3. Practical Usage Example

```javascript
// 1. Token generation upon login
const login = async (req, res) => {
  const { email, password } = req.body;

  // Verify User
  const user = await User.findOne({ email });
  if (!user) return res.status(401).json({ message: "Invalid credentials" });

  // Verify Password
  const isMatch = await user.comparePassword(password);
  if (!isMatch) return res.status(401).json({ message: "Invalid credentials" });

  // Generate Token
  const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
    expiresIn: "7d",
  });

  res.json({ token });
};

// 2. Processing requests that require authentication
const authMiddleware = (req, res, next) => {
  // Extract Token
  const token = req.headers.authorization?.split(" ")[1];
  if (!token) return res.status(401).json({ message: "No token provided" });

  try {
    // Verify Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Add verified user info to the request object
    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid token" });
  }
};
```

In summary, JWT:

1. Encodes the payload as Base64 during token creation
2. Hashes the signature using the `JWT_SECRET`
3. Re-calculates and compares the signature during verification
4. Uses the payload data only if the signature matches

Conclusion: `JWT_SECRET` is critical security information

---

## Step 2: Database

Let's move on to Step 2, the Database. First, we'll look at the MongoDB connection setup and model structure.

### 1. MongoDB Connection Setup

```javascript
// In app.js
mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("MongoDB Connected"))
  .catch((err) => console.error("MongoDB Connection Error:", err));
```

### 2. Model Structure

#### A. User Model

```javascript
const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      minlength: 3,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 6,
    },
    lastLoginAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true, // Automatically generates createdAt, updatedAt
  },
);
```

Features:

- Automatic password hashing (bcrypt)
- Prevention of duplicate email/username
- Tracking of last login time
- Automatic timestamp generation

#### B. Post Model

```javascript
const postSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    content: {
      type: String,
      required: true,
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    tags: [
      {
        type: String,
        trim: true,
      },
    ],
    likes: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    comments: [commentSchema],
  },
  {
    timestamps: true,
  },
);
```

Features:

- Includes comment schema
- Author reference (linked with User model)
- Tagging functionality
- Like functionality
- Automatic timestamp generation

### 3. Relationship Setup

- Post and User are linked by `ObjectId`.
- Comments are also linked with User.
- Likes are also linked with User.

### 4. Database Operation Examples

```javascript
// Create User
const user = new User({
  username: "john_doe",
  email: "john@example.com",
  password: "password123",
});
await user.save();

// Create Post
const post = new Post({
  title: "My First Post",
  content: "Hello World!",
  author: user._id,
  tags: ["first", "hello"],
});
await post.save();

// Lookup Post (including author info)
const postWithAuthor = await Post.findById(postId)
  .populate("author", "username email")
  .populate("comments.author", "username");
```

Advantages of this structure:

1. Schema validation ensures data integrity
2. Automatic timestamps make time tracking easy
3. Relationship settings make data lookup convenient
4. Automatic password hashing strengthens security

## Bcrypt Explanation

Ah, great question! The bcrypt hash value includes the salt.

Looking at a password hashed with bcrypt:

```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

This string is composed as follows:

1. `$2a$` - Algorithm version
2. `10` - Hash cost factor
3. `N9qo8uLOickgx2ZMRZoMye` - 22-character salt
4. `IjZAgcfl7p92ldGxad68LJZdL17lhWy` - The actual hash value

Therefore, the process for `bcrypt.compare()` is:

1. Extract the salt from the stored hash value
2. Generate a hash using the entered password and the extracted salt
3. Compare the newly generated hash with the stored hash

In example code:

```javascript
// 1. When saving a password
const password = "password123";
const salt = await bcrypt.genSalt(10);
const hash = await bcrypt.hash(password, salt);
// hash = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"

// 2. When verifying a password
const isMatch = await bcrypt.compare("password123", hash);
// Internally:
// 1. Extract salt from hash ("N9qo8uLOickgx2ZMRZoMye")
// 2. Generate new hash with "password123" + "N9qo8uLOickgx2ZMRZoMye"
// 3. Compare new hash with stored hash
```

Because the salt is included in the hash value:

1. No need to store the salt separately
2. Different hash values are generated even for the same password
3. Verification is possible with just the hash value

Is including the salt in the hash a vulnerability? No. This is a key security feature of bcrypt.

I will explain the reasons:

1. **Purpose of Salt**:
   - Salt exists to create different hashes even for the same password
   - It exists to prevent rainbow table attacks
   - Salt itself is not meant to protect the password

2. **Structure of Hash Value**:

```
$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
```

- Even if the salt is exposed, the password cannot be reverse-engineered
- This is because bcrypt is a one-way hash function

3. **Attack Scenario**:
   - Assume an attacker obtained the hash value
   - They can know the salt, but:
     - They don't know the password
     - The hash function is one-way
     - Every user has a different salt
   - Therefore, only brute force attacks are possible
   - However, bcrypt is an intentionally slow hash function

4. **Security Strength Factors of bcrypt**:
   - One-way hash (irreversible)
   - Intentionally slow hash function
   - Different salt for every user
   - Hash strength adjustable with cost factor

Example:

```javascript
// User A's password "password123"
const hashA = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy";

// User B's same password "password123"
const hashB = "$2a$10$DifferentSaltHereDifferentHashValue";

// Both hash values are completely different
// Even if the salt is exposed, the password cannot be known
```

This is why it's safe:

1. Salt is not meant to protect the password
2. Salt is meant to ensure diversity of the hash value
3. The actual password is protected by the hash function
4. bcrypt uses an intentionally slow hash function

## Why Use Populate?

`populate` is used to handle reference relationships in MongoDB.

In the Post model:

```javascript
const postSchema = new mongoose.Schema({
  author: {
    type: mongoose.Schema.Types.ObjectId, // Stores only the User model ID
    ref: "User",
    required: true,
  },
  comments: [
    {
      author: {
        type: mongoose.Schema.Types.ObjectId, // Stores only the User model ID
        ref: "User",
        required: true,
      },
    },
  ],
});
```

Here, `author` and `comments.author` store only the User's ID, not the actual User object.

Example:

```javascript
// Actual data stored in DB
{
  _id: "post123",
  title: "My Post",
  author: "user456",  // Only User ID is stored
  comments: [
    {
      content: "Great post!",
      author: "user789"  // Only User ID is stored
    }
  ]
}
```

If you don't use `populate`:

```javascript
const post = await Post.findById(req.params.id);
// Result:
{
  _id: "post123",
  title: "My Post",
  author: "user456",  // Only ID exists
  comments: [
    {
      content: "Great post!",
      author: "user789"  // Only ID exists
    }
  ]
}
```

If you use `populate`:

```javascript
const post = await Post.findById(req.params.id)
  .populate('author', 'username')  // Convert author field ID to actual User object
  .populate('comments.author', 'username');  // Also convert author in comments

// Result:
{
  _id: "post123",
  title: "My Post",
  author: {
    _id: "user456",
    username: "john_doe"  // Actual user info
  },
  comments: [
    {
      content: "Great post!",
      author: {
        _id: "user789",
        username: "jane_doe"  // Actual user info
      }
    }
  ]
}
```

The reasons for doing this:

1. **Data Normalization**: Prevent duplicate data storage
2. **Data Consistency**: Changes to user info reflect in one place
3. **Efficient Storage**: Store only necessary info
4. **Flexible Lookup**: Selectively retrieve only necessary information

The reason for using `select: 'username'`:

1. Reduce network traffic by retrieving only required fields
2. Prevent exposure of sensitive data (email, password, etc.)
3. Optimize response data size

---

## Step 3: Authentication System

Yes, we will look into Step 3, the Authentication System.

### 1. Registration (Register)

```javascript
// backend/src/controllers/userController.js
const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // 1. Check for duplicate user
    const existingUser = await User.findOne({ $or: [{ email }, { username }] });
    if (existingUser) {
      return res.status(400).json({ message: "User already exists" });
    }

    // 2. Create new user
    const user = new User({ username, email, password });
    await user.save();

    // 3. Generate JWT Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    // 4. Response
    res.status(201).json({
      message: "User registered successfully",
      token,
      user: {
        _id: user._id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error registering user", error: error.message });
  }
};
```

### 2. Login (Login)

```javascript
// backend/src/controllers/userController.js
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // 1. Find User
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // 2. Verify Password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // 3. Update Last Login Time
    user.lastLoginAt = new Date();
    await user.save();

    // 4. Generate JWT Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    // 5. Response
    res.json({
      message: "Login successful",
      token,
      user: {
        _id: user._id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLoginAt: user.lastLoginAt,
      },
    });
  } catch (error) {
    res.status(500).json({ message: "Error logging in", error: error.message });
  }
};
```

### 3. Auth Middleware

```javascript
// backend/src/middleware/auth.js
const auth = async (req, res, next) => {
  try {
    // 1. Extract Token
    const token = req.header("Authorization")?.replace("Bearer ", "");

    if (!token) {
      throw new Error();
    }

    // 2. Verify Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 3. Verify User
    const user = await User.findById(decoded.userId);
    if (!user) {
      throw new Error();
    }

    // 4. Add User Info to Request Object
    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    res.status(401).json({ message: "Please authenticate" });
  }
};
```

### 4. User Profile Lookup

```javascript
// backend/src/controllers/userController.js
const getProfile = async (req, res) => {
  try {
    // 1. Lookup User Info (exclude password)
    const user = await User.findById(req.user._id).select("-password");

    // 2. Response
    res.json({
      user: {
        _id: user._id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLoginAt: user.lastLoginAt,
      },
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: "Error fetching profile", error: error.message });
  }
};
```

Features of this authentication system:

1. JWT-based authentication
2. Password hashing (bcrypt)
3. Token expiration setup (7 days)
4. Tracking of last login time
5. Exclusion of sensitive information (password, etc.)

API Endpoints:

- POST `/api/users/register` - Registration
- POST `/api/users/login` - Login
- GET `/api/users/profile` - Profile lookup (Authentication required)

## auth.js Operation

Ah, yes! I will explain the entire authentication flow starting from routing.

### 1. Route Configuration

```javascript
// backend/src/routes/userRoutes.js
const router = express.Router();

// Routes that don't require authentication
router.post("/register", register); // Registration
router.post("/login", login); // Login

// Routes that require authentication
router.get("/profile", auth, getProfile); // Profile lookup
```

```javascript
// backend/src/routes/postRoutes.js
const router = express.Router();

// Routes that don't require authentication
router.get("/", getPosts); // Post list lookup
router.get("/:id", getPost); // Post detail lookup

// Routes that require authentication
router.post("/", auth, createPost); // Create post
router.put("/:id", auth, updatePost); // Edit post
router.delete("/:id", auth, deletePost); // Delete post
// ... other routes requiring authentication
```

### 2. Auth Middleware Operation

```javascript
// backend/src/middleware/auth.js
const auth = async (req, res, next) => {
  try {
    // 1. Extract Token from Authorization header
    const token = req.header("Authorization")?.replace("Bearer ", "");

    if (!token) {
      throw new Error();
    }

    // 2. Verify Token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 3. Verify User
    const user = await User.findById(decoded.userId);
    if (!user) {
      throw new Error();
    }

    // 4. Add User Info to Request Object
    req.user = user;
    req.token = token;
    next(); // Proceed to next middleware/controller
  } catch (error) {
    res.status(401).json({ message: "Please authenticate" });
  }
};
```

### 3. Overall Request Processing Flow

1. **Request not requiring authentication** (e.g., Post list lookup)

```
Client → GET /api/posts → Express Router → getPosts Controller → Response
```

2. **Request requiring authentication** (e.g., Create post)

```
Client → POST /api/posts → Express Router → auth Middleware → createPost Controller → Response
```

### 4. Practical Operation Example

```javascript
// 1. Post list lookup (Authentication not required)
fetch("/api/posts")
  .then((res) => res.json())
  .then((posts) => console.log(posts));

// 2. Create post (Authentication required)
fetch("/api/posts", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    title: "New Post",
    content: "Hello World",
  }),
})
  .then((res) => res.json())
  .then((post) => console.log(post));
```

### 5. Upon Authentication Failure

```javascript
// If token is missing or invalid
fetch("/api/posts", {
  method: "POST",
  headers: {
    Authorization: "Bearer invalid_token",
  },
}).then((res) => {
  if (res.status === 401) {
    // Authentication failure
    // Redirect to login page
  }
});
```

So:

1. Decide whether to use `auth` middleware in the route
2. Requests requiring authentication must pass through `auth` middleware
3. `auth` middleware adds user info to the request object after token verification
4. Controller uses user info via `req.user`

---

## Step 4: API Endpoints

Yes, we will look into Step 4, the API Endpoints. First, we'll check the currently implemented API endpoints.

### 1. Users API Endpoints

```javascript
// backend/src/routes/userRoutes.js
const router = express.Router();

// Endpoints that don't require authentication
router.post("/register", register); // Registration
router.post("/login", login); // Login

// Endpoints that require authentication
router.get("/profile", auth, getProfile); // Profile lookup
```

### 2. Posts API Endpoints

```javascript
// backend/src/routes/postRoutes.js
const router = express.Router();

// Endpoints that don't require authentication
router.get("/", getPosts); // Post list lookup
router.get("/:id", getPost); // Post detail lookup

// Endpoints that require authentication
router.post("/", auth, createPost); // Create post
router.put("/:id", auth, updatePost); // Edit post
router.delete("/:id", auth, deletePost); // Delete post

// Comment-related endpoints
router.post("/:id/comments", auth, addComment); // Write comment
router.put("/:id/comments/:commentId", auth, editComment); // Edit comment
router.delete("/:id/comments/:commentId", auth, deleteComment); // Delete comment

// Reply-related endpoints
router.post("/:id/comments/:commentId/replies", auth, addReply); // Write reply
router.put("/:id/comments/:commentId/replies/:replyId", auth, editReply); // Edit reply
router.delete("/:id/comments/:commentId/replies/:replyId", auth, deleteReply); // Delete reply

// Like-related endpoints
router.post("/:id/like", auth, likePost); // Like post
```

### 3. API Request/Response Examples

#### A. Registration

```javascript
// Request
POST /api/users/register
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "password123"
}

// Response
{
  "message": "User registered successfully",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "user123",
    "username": "john_doe",
    "email": "john@example.com",
    "createdAt": "2024-03-20T12:00:00.000Z",
    "updatedAt": "2024-03-20T12:00:00.000Z"
  }
}
```

#### B. Create Post

```javascript
// Request
POST /api/posts
Headers: {
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
{
  "title": "My First Post",
  "content": "Hello World!",
  "tags": ["first", "hello"]
}

// Response
{
  "message": "Post created successfully",
  "post": {
    "_id": "post123",
    "title": "My First Post",
    "content": "Hello World!",
    "author": {
      "_id": "user123",
      "username": "john_doe"
    },
    "tags": ["first", "hello"],
    "createdAt": "2024-03-20T12:00:00.000Z"
  }
}
```

#### C. Write Comment

```javascript
// Request
POST /api/posts/post123/comments
Headers: {
  "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
{
  "content": "Great post!"
}

// Response
{
  "message": "Comment added successfully",
  "comment": {
    "_id": "comment123",
    "content": "Great post!",
    "author": {
      "_id": "user123",
      "username": "john_doe"
    },
    "createdAt": "2024-03-20T12:00:00.000Z"
  }
}
```

### 4. Error Processing

```javascript
// 400 Bad Request
{
  "message": "Invalid input data",
  "errors": {
    "username": "Username is required",
    "email": "Invalid email format"
  }
}

// 401 Unauthorized
{
  "message": "Please authenticate"
}

// 403 Forbidden
{
  "message": "You don't have permission to perform this action"
}

// 404 Not Found
{
  "message": "Post not found"
}

// 500 Internal Server Error
{
  "message": "Something went wrong",
  "error": "Error message details"
}
```

### 5. RESTful API Design Principles

1. **Resource-based URL**:
   - `/api/posts` - Post resource
   - `/api/posts/:id/comments` - Comment resource

2. **HTTP Method Usage**:
   - GET: Lookup
   - POST: Create
   - PUT: Edit
   - DELETE: Delete

3. **Hierarchical Structure**:
   - Post → Comment → Reply

4. **Consistent Response Format**:
   - Success: `{ message, data }`
   - Failure: `{ message, error }`

5. **Status Code Usage**:
   - 200: Success
   - 201: Creation success
   - 400: Bad request
   - 401: Authentication required
   - 403: No permission
   - 404: No resource
   - 500: Server error

Advantages of this API structure:

1. Intuitive URL structure
2. Consistent response format
3. Clear error processing
4. Hierarchical resource structure
5. Compliance with RESTful principles

## UserController

Yes, we will look into the entire content of `userController.js`.

I will explain each function in `userController.js` in detail:

### 1. Registration (register)

```javascript
// backend/src/controllers/userController.js
const register = async (req, res) => {
  try {
    // 1. Extract request data
    const { username, email, password } = req.body;

    // 2. Check for duplicate user
    const existingUser = await User.findOne({
      $or: [{ email }, { username }],
    });
    if (existingUser) {
      return res.status(400).json({
        message: "User already exists",
      });
    }

    // 3. Create new user
    const user = new User({ username, email, password });
    await user.save();

    // 4. Generate JWT Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    // 5. Response
    res.status(201).json({
      message: "User registered successfully",
      token,
      user: {
        _id: user._id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: "Error registering user",
      error: error.message,
    });
  }
};
```

### 2. Login (login)

```javascript
// backend/src/controllers/userController.js
const login = async (req, res) => {
  try {
    // 1. Extract request data
    const { email, password } = req.body;

    // 2. Find User
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(401).json({
        message: "Invalid credentials",
      });
    }

    // 3. Verify Password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        message: "Invalid credentials",
      });
    }

    // 4. Update last login time
    user.lastLoginAt = new Date();
    await user.save();

    // 5. Generate JWT Token
    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: "7d",
    });

    // 6. Response
    res.json({
      message: "Login successful",
      token,
      user: {
        _id: user._id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLoginAt: user.lastLoginAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: "Error logging in",
      error: error.message,
    });
  }
};
```

### 3. Profile Lookup (getProfile)

```javascript
// backend/src/controllers/userController.js
const getProfile = async (req, res) => {
  try {
    // 1. Lookup user info (exclude password)
    const user = await User.findById(req.user._id).select("-password");

    // 2. Response
    res.json({
      user: {
        _id: user._id,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        lastLoginAt: user.lastLoginAt,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: "Error fetching profile",
      error: error.message,
    });
  }
};
```

### Key Features

1. **Error Processing**:
   - Process all errors with try-catch
   - Use appropriate HTTP status codes
   - Include error messages

2. **Security**:
   - Password not included in responses
   - Use JWT tokens
   - Check for duplicate users

3. **Data Verification**:
   - Confirm email/username duplication
   - Verify password

4. **Response Format**:
   - Consistent JSON response structure
   - Include only necessary info
   - Clear messages

5. **Status Codes**:
   - 201: Creation success
   - 400: Bad request
   - 401: Authentication failure
   - 500: Server error

---

## Step 5: Middleware

Yes, we will look into Step 5, the Middleware. First, we'll check the middleware configuration in `app.js`.

I will explain the middleware by dividing them into three major parts:

### 1. CORS Configuration

```javascript
// backend/src/app.js
const corsOptions = {
  // 1. Allowed origin setup
  origin: function (origin, callback) {
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },

  // 2. Allowed HTTP methods
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],

  // 3. Allowed headers
  allowedHeaders: ["Content-Type", "Authorization"],

  // 4. Allow authentication info
  credentials: true,

  // 5. OPTIONS request status code
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));
```

Features of CORS configuration:

1. Allow only specific domains
2. Allow only necessary HTTP methods
3. Allow only necessary headers
4. Allow transmission of authentication info

### 2. Logging Middleware

```javascript
// backend/src/app.js
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});
```

Features of logging middleware:

1. Record all requests
2. Include timestamp
3. Record HTTP method and URL
4. Support asynchronous processing

### 3. Error Processing Middleware

```javascript
// backend/src/app.js
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something went wrong!" });
});
```

Features of error processing middleware:

1. Catch all errors
2. Log stack trace
3. Send error response to client
4. Return 500 status code

### 4. Other Middleware

```javascript
// JSON parsing middleware
app.use(express.json());

// Route middleware
app.use("/api/users", userRoutes);
app.use("/api/posts", postRoutes);
```

### 5. Middleware Execution Order

1. CORS Middleware
   - Confirm request origin
   - Verify if it's an allowed domain

2. JSON Parsing Middleware
   - Parse request body into JSON
   - Add data to `req.body`

3. Logging Middleware
   - Record request info
   - Facilitate debugging

4. Route Middleware
   - Deliver request to appropriate route
   - Execute controller

5. Error Processing Middleware
   - Process occurred errors
   - Send error response

### 6. Middleware Usage Example

```javascript
// 1. CORS Request
fetch("http://localhost:8080/api/posts", {
  method: "GET",
  credentials: "include",
  headers: {
    "Content-Type": "application/json",
  },
});

// 2. Log Output
// 2024-03-20T12:00:00.000Z - GET /api/posts

// 3. Upon Error
// 2024-03-20T12:00:00.000Z - Error: Not allowed by CORS
// { message: 'Something went wrong!' }
```

Advantages of this middleware structure:

1. Security enhancement (CORS)
2. Ease of debugging (logging)
3. Consistency in error processing
4. Standardization of request/response processing
5. Code reusability

## CORS (Cross-Origin Resource Sharing)

CORS (Cross-Origin Resource Sharing) is one of the security policies of web browsers.

### Why CORS is Needed

Let's take an example:

1. Frontend: `http://localhost:3000` (React App)
2. Backend: `http://localhost:8080` (Express Server)

At this time, if you send an API request from the frontend to the backend:

```javascript
// Frontend code (http://localhost:3000)
fetch("http://localhost:8080/api/posts")
  .then((res) => res.json())
  .then((data) => console.log(data));
```

This request is a request to a **different origin (Cross-Origin)**:

- Origin = Protocol + Domain + Port
- `http://localhost:3000` ≠ `http://localhost:8080`

### What if There's No CORS?

There could be malicious websites:

```javascript
// Malicious website (http://evil.com)
fetch("http://your-bank.com/api/transfer", {
  method: "POST",
  body: JSON.stringify({
    to: "hacker",
    amount: 1000000,
  }),
});
```

To prevent such situations, browsers:

1. Basically block requests to different origins
2. Only allow access to origins explicitly permitted by the server

### CORS Setup Example

```javascript
// backend/src/app.js
const corsOptions = {
  // 1. Allowed origin list
  origin: [
    "http://localhost:3000", // Development environment
    "http://192.168.219.120:3000", // Local network
    "https://your-domain.com", // Production environment
  ],

  // 2. Allowed HTTP methods
  methods: ["GET", "POST", "PUT", "DELETE"],

  // 3. Allowed headers
  allowedHeaders: ["Content-Type", "Authorization"],

  // 4. Allow authentication info (Cookie, HTTP authentication)
  credentials: true,
};

app.use(cors(corsOptions));
```

### CORS Operation Mode

1. **Simple Request**:

```javascript
// Frontend
fetch("http://localhost:8080/api/posts").then((res) => res.json());
```

- GET, POST, HEAD methods
- Use only basic headers
- Browser automatically checks CORS

2. **Preflight Request**:

```javascript
// Frontend
fetch("http://localhost:8080/api/posts", {
  method: "PUT",
  headers: {
    "Content-Type": "application/json",
    Authorization: "Bearer token",
  },
});
```

- Request first with OPTIONS method
- Confirm if the server allows it
- If allowed, send the actual request

### CORS Error Example

```javascript
// 1. Disallowed origin
Access to fetch at 'http://localhost:8080/api/posts' from origin
'http://evil.com' has been blocked by CORS policy

// 2. Disallowed method
Method PUT is not allowed by Access-Control-Allow-Methods

// 3. Disallowed header
Header 'X-Custom-Header' is not allowed by Access-Control-Allow-Headers
```

### Advantages of CORS

1. **Security Enhancement**:
   - Accessible only to allowed origins
   - Prevent CSRF attacks
   - Prevent data leaks

2. **Clear Access Control**:
   - Specify which origins are accessible
   - Specify which methods are allowed
   - Specify which headers are allowed

3. **Flexible Setup**:
   - Setup by development/production environment
   - Can allow various origins
   - Allow only required features

Yes, I will explain CORS more easily.

### 1. Situations Where CORS is Needed

For example, assume you are making a website:

```
Frontend: http://localhost:3000 (React App)
Backend: http://localhost:8080 (Express Server)
```

At this time, if you request data from the frontend to the backend:

```javascript
// Frontend code
fetch("http://localhost:8080/api/posts")
  .then((res) => res.json())
  .then((posts) => console.log(posts));
```

This request is a request to a **different origin**:

- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8080`
- Since the ports are different, they are different origins

### 2. What if There's No CORS?

Assume there's a malicious website:

```
Malicious site: http://evil.com
```

This site can send a request to your backend:

```javascript
// Malicious site code
fetch("http://localhost:8080/api/posts", {
  method: "POST",
  body: JSON.stringify({
    title: "Hacked Post",
    content: "This is a hack",
  }),
});
```

To prevent such situations, browsers:

1. Basically block requests to different origins
2. Only allow if the server says "This origin is okay!"

### 3. How to Set CORS

```javascript
// backend/src/app.js
const corsOptions = {
  // 1. Allowed origin list
  origin: [
    "http://localhost:3000", // Development environment
    "https://your-site.com", // Actual site
  ],

  // 2. Allowed HTTP methods
  methods: ["GET", "POST", "PUT", "DELETE"],

  // 3. Allow authentication info (Cookie, etc.)
  credentials: true,
};

app.use(cors(corsOptions));
```

### 4. Practical Operation Example

1. **Normal Request**:

```javascript
// Frontend (http://localhost:3000)
fetch("http://localhost:8080/api/posts")
  .then((res) => res.json())
  .then((posts) => console.log(posts));
```

- Browser: "This request came from an allowed origin!"
- Server: "Yeah, it's okay!"
- Result: Request success

2. **Malicious Request**:

```javascript
// Malicious site (http://evil.com)
fetch("http://localhost:8080/api/posts")
  .then((res) => res.json())
  .then((posts) => console.log(posts));
```

- Browser: "This request came from a disallowed origin!"
- Server: Cannot even send a response
- Result: CORS error occurs

### 5. Limits of CORS

CORS only operates in browsers:

1. Requests through browsers → CORS applied
2. Requests outside browsers → CORS not applied

Example:

```bash
# Request via curl
curl http://localhost:8080/api/posts
```

- CORS policy not applied
- Server can receive the request

### 6. Actual Security

CORS is only basic security; actual security must be done on the server:

```javascript
// 1. Verify authentication
app.use("/api/posts", auth, postRoutes);

// 2. Limit requests
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Max requests per IP
  }),
);
```

### Summary

1. CORS is:
   - A security policy of browsers
   - Limits requests from other origins
   - Accessible only to allowed origins

2. CORS setup includes:
   - Which origins to allow
   - Which methods to allow
   - Whether to allow authentication info

3. Actual security involves:
   - Authentication/Authorization on the server
   - API security
   - Request limits

---

## Step 6: Security

Yes, we will look into Step 6, the Security. First, we'll check the currently implemented security-related codes.

### 1. CORS Security Configuration

```javascript
// backend/src/app.js
const corsOptions = {
  // 1. Limit allowed origins
  origin: ["http://localhost:3000", "http://192.168.219.120:3000"],

  // 2. Limit allowed methods
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],

  // 3. Limit allowed headers
  allowedHeaders: ["Content-Type", "Authorization"],

  // 4. Configure authentication info
  credentials: true,
};

app.use(cors(corsOptions));
```

### 2. Input Data Verification

```javascript
// backend/src/controllers/userController.js
const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // 1. Confirm duplicate user
    const existingUser = await User.findOne({
      $or: [{ email }, { username }],
    });
    if (existingUser) {
      return res.status(400).json({
        message: "User already exists",
      });
    }

    // 2. Create new user
    const user = new User({ username, email, password });
    await user.save();
    // ...
  } catch (error) {
    res.status(500).json({
      message: "Error registering user",
      error: error.message,
    });
  }
};
```

### 3. Error Processing and Logging

```javascript
// backend/src/app.js
// 1. Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// 2. Error processing
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something went wrong!" });
});
```

### 4. Additional Security Configuration Proposals

1. **Add Rate Limiting**:

```javascript
// backend/src/app.js
const rateLimit = require("express-rate-limit");

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Max requests per IP
});

app.use(limiter);
```

2. **Use Helmet**:

```javascript
// backend/src/app.js
const helmet = require("helmet");

app.use(helmet()); // Configure security headers
```

3. **Strengthen Input Data Verification**:

```javascript
// backend/src/middleware/validator.js
const { body, validationResult } = require("express-validator");

const validateUser = [
  body("username")
    .trim()
    .isLength({ min: 3 })
    .withMessage("Username must be at least 3 characters long"),
  body("email").isEmail().normalizeEmail().withMessage("Invalid email address"),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters long"),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    next();
  },
];
```

4. **Strengthen Error Logging**:

```javascript
// backend/src/middleware/errorLogger.js
const errorLogger = (err, req, res, next) => {
  console.error({
    timestamp: new Date().toISOString(),
    method: req.method,
    url: req.url,
    error: err.message,
    stack: err.stack,
    user: req.user ? req.user._id : "anonymous",
  });
  next(err);
};

app.use(errorLogger);
```

### 5. Security Checklist

1. **CORS Security**:
   - Set only allowed origins
   - Allow only required methods
   - Allow only required headers

2. **Input Data Verification**:
   - Verify all input data
   - Prevent SQL injection
   - Prevent XSS attacks

3. **Error Processing**:
   - Hide sensitive error information
   - Appropriate error logging
   - User-friendly error messages

4. **Authentication/Authorization**:
   - JWT token verification
   - Password hashing
   - Session management

5. **Additional Security**:
   - Rate limiting
   - Security headers
   - Use HTTPS

### 6. Security Monitoring

```javascript
// backend/src/middleware/securityMonitor.js
const securityMonitor = (req, res, next) => {
  // 1. Request monitoring
  console.log({
    timestamp: new Date().toISOString(),
    ip: req.ip,
    method: req.method,
    url: req.url,
    userAgent: req.headers["user-agent"],
  });

  // 2. Detect suspicious requests
  if (isSuspiciousRequest(req)) {
    console.warn("Suspicious request detected:", req);
  }

  next();
};

app.use(securityMonitor);
```

Advantages of this security structure:

1. Multi-layered security
2. Real-time monitoring
3. Automated verification
4. Detailed logging
5. Scalable structure

## User Model Operation (Mongoose)

Ah, yes, you understood correctly! I will explain the Mongoose model and instance creation process in detail.

### 1. User Model Definition

```javascript
// backend/src/models/User.js
const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
  },
  email: {
    type: String,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
});

// Model creation
const User = mongoose.model("User", userSchema);
```

### 2. Instance Creation Process

```javascript
// 1. Upon calling new User()
const user = new User({
  username: "john_doe",
  email: "john@example.com",
  password: "password123",
});

// What happens internally:
// 1. mongoose creates a new document instance based on userSchema
// 2. Initialize document with input data
// 3. Apply defaults, verification, etc., defined in the schema
```

### 3. save() Method

```javascript
// 2. Upon calling user.save()
await user.save();

// What happens internally:
// 1. Execute pre('save') hook defined in schema
// 2. Data verification
// 3. Actual storage in MongoDB
// 4. Execute post('save') hook
```

### 4. Practical Operation Example

```javascript
// backend/src/controllers/userController.js
const register = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // 1. Create new User instance
    const user = new User({
      username,
      email,
      password,
    });
    // At this point, it's not yet stored in DB
    // Status exists only in memory

    // 2. Store in DB by calling save()
    await user.save();
    // At this point, it's actually stored in DB
    // pre('save') hook is executed and password is hashed

    // 3. Return created user info
    res.status(201).json({
      message: "User registered successfully",
      user: {
        _id: user._id, // ID generated by MongoDB
        username: user.username,
        email: user.email,
      },
    });
  } catch (error) {
    res.status(500).json({
      message: "Error registering user",
      error: error.message,
    });
  }
};
```

### 5. Mongoose's Special Features

1. **Schema Methods**:

```javascript
// Add method to User model
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

// Usage
const isMatch = await user.comparePassword("password123");
```

2. **Middleware (Hooks)**:

```javascript
// Hook executed before storage
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();

  // Password hashing
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});
```

3. **Virtual Fields**:

```javascript
// Field not actually stored in DB
userSchema.virtual("fullName").get(function () {
  return `${this.firstName} ${this.lastName}`;
});
```

### 6. Advantages of Mongoose

1. **Object-Oriented**:
   - Can be treated like JavaScript objects
   - Can add methods and properties

2. **Schema-based**:
   - Define data structure
   - Type verification
   - Setup default values

3. **Middleware Support**:
   - Pre/Post processing for storage
   - Verification
   - Data conversion

4. **Query Builder**:
   - Chaining-style queries
   - Easy to write complex queries

---

## Step 7: Testing and Deployment

Yes, we will look into Step 7, the Testing and Deployment stages. I will explain each part in detail.

### 1. API Testing

1. **Unit Testing Using Jest**:

```javascript
// backend/src/tests/user.test.js
const request = require("supertest");
const app = require("../app");
const User = require("../models/User");

describe("User API Tests", () => {
  // Initialize DB before testing
  beforeEach(async () => {
    await User.deleteMany({});
  });

  // Registration test
  test("should register a new user", async () => {
    const res = await request(app).post("/api/users/register").send({
      username: "testuser",
      email: "test@example.com",
      password: "password123",
    });

    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty("message", "User registered successfully");
  });

  // Login test
  test("should login existing user", async () => {
    // Create user first
    await User.create({
      username: "testuser",
      email: "test@example.com",
      password: "password123",
    });

    const res = await request(app).post("/api/users/login").send({
      email: "test@example.com",
      password: "password123",
    });

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty("token");
  });
});
```

2. **API Testing Using Postman**:

```javascript
// backend/postman/board-service.postman_collection.json
{
  "info": {
    "name": "Board Service API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "User Management",
      "item": [
        {
          "name": "Register User",
          "request": {
            "method": "POST",
            "url": "{{baseUrl}}/api/users/register",
            "body": {
              "mode": "raw",
              "raw": "{\n  \"username\": \"testuser\",\n  \"email\": \"test@example.com\",\n  \"password\": \"password123\"\n}",
              "options": {
                "raw": {
                  "language": "json"
                }
              }
            }
          }
        }
        // ... (other API endpoint tests can also be added)
      ]
    }
  ]
}
```

- By using Postman, you can actually call the API, check the response, and easily test various scenarios (normal/error).

---

### 2. Deployment

1. **Environment Variable Management**
   - Store sensitive info like DB address, JWT secret, port, etc., in the `.env` file.
   - Example:

```
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/board
JWT_SECRET=your_jwt_secret
PORT=8080
```

2. **Production Build and Execution**
   - `npm run build` (if frontend exists)
   - `npm start` or `node src/app.js`

3. **Server Deployment**
   - Upload to cloud services (AWS, GCP, Azure, Vercel, Heroku, etc.) or VPS (Virtual Private Server).
   - Example: Heroku Deployment

```bash
heroku create board-service
heroku config:set MONGODB_URI=...
git push heroku main
```

4. **Using Process Manager**
   - Manage server stably with PM2, etc.

```bash
npm install pm2 -g
pm2 start src/app.js --name board-service
pm2 save
pm2 startup
```

5. **Apply HTTPS**
   - Apply SSL certificate with Let's Encrypt, etc.
   - Configure reverse proxy like Nginx, Apache, etc.

---

### 3. Post-Deployment Checklist

- Confirm normal API operation (test automation/manual)
- Re-confirm security setup (environment variables, CORS, authentication, etc.)
- Logging and monitoring configuration
- Backup and disaster preparedness

## API tests

Below are 10 examples of API test scenarios frequently used in "Board Services."
Each example provides the request method, URL, Body, and description so they can be used in Postman.

---

### 1. Registration (Register User)

- **Method:** POST
- **URL:** http://localhost:8080/api/users/register
- **Body (JSON):**

```json
{
  "username": "testuser1",
  "email": "test1@example.com",
  "password": "password123"
}
```

- **Description:** Register a new user.

---

### 2. Login (Login User)

- **Method:** POST
- **URL:** http://localhost:8080/api/users/login
- **Body (JSON):**

```json
{
  "email": "test1@example.com",
  "password": "password123"
}
```

- **Description:** A registered user logs in. (Receives JWT token in response)

---

### 3. My Info Lookup (Get My Profile)

- **Method:** GET
- **URL:** http://localhost:8080/api/users/me
- **Headers:**
  - Authorization: Bearer {JWT_TOKEN}
- **Description:** Lookup info of the logged-in user.

---

### 4. Post List Lookup (Get Posts)

- **Method:** GET
- **URL:** http://localhost:8080/api/posts
- **Description:** Lookup the entire list of posts.

---

### 5. Create Post (Create Post)

- **Method:** POST
- **URL:** http://localhost:8080/api/posts
- **Headers:**
  - Authorization: Bearer {JWT_TOKEN}
- **Body (JSON):**

```json
{
  "title": "First Post",
  "content": "This is post content."
}
```

- **Description:** Create a new post.

---

### 6. Post Detail Lookup (Get Post Detail)

- **Method:** GET
- **URL:** http://localhost:8080/api/posts/1
- **Description:** Lookup detail information of a specific post. (1 is the post ID)

---

### 7. Edit Post (Update Post)

- **Method:** PUT
- **URL:** http://localhost:8080/api/posts/1
- **Headers:**
  - Authorization: Bearer {JWT_TOKEN}
- **Body (JSON):**

```json
{
  "title": "Edited post title",
  "content": "Edited post content"
}
```

- **Description:** Edit a specific post.

---

### 8. Delete Post (Delete Post)

- **Method:** DELETE
- **URL:** http://localhost:8080/api/posts/1
- **Headers:**
  - Authorization: Bearer {JWT_TOKEN}
- **Description:** Delete a specific post.

---

### 9. Write Comment (Add Comment)

- **Method:** POST
- **URL:** http://localhost:8080/api/posts/1/comments
- **Headers:**
  - Authorization: Bearer {JWT_TOKEN}
- **Body (JSON):**

```json
{
  "content": "This is comment content."
}
```

- **Description:** Write a comment on a specific post.

---

### 10. Delete Comment (Delete Comment)

- **Method:** DELETE
- **URL:** http://localhost:8080/api/posts/1/comments/5
- **Headers:**
  - Authorization: Bearer {JWT_TOKEN}
- **Description:** Delete a specific comment on a specific post. (1 is post ID, 5 is comment ID)

---

#### Reference

- For `{JWT_TOKEN}`, use the token received in response during login.
- Actual API paths (like `/api/posts/1`) may vary depending on the project routing.
- Saving each request as a "Collection" in Postman is convenient for repetitive testing.

## Production Environment Configuration Plan

Yes, that's correct!
The structure of placing **Nginx as a reverse proxy in front of the Node.js (Express) server** is the most common.

---

## Structure Diagram

```
[Internet User]
        │
   (Port 80/443)
        │
   [ Nginx Server ]
        │
   (Internal port like 8080)
        │
 [ Node.js(Express) Server ]
```

---

## Operation Mode

1. **User** accesses `http://yourdomain.com` or `https://yourdomain.com`
2. **Nginx** receives the request at port 80 (HTTP) or 443 (HTTPS)
3. Nginx delivers the request to the internal Node.js server (e.g., `localhost:8080`) (proxy_pass)
4. Node.js creates a response → Nginx delivers the response back to the user

---

## Nginx Reverse Proxy Setup Example

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;  # Proxy to Node.js server
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## Summary of Advantages

- **Security**: Node.js server is not directly exposed to the outside
- **HTTPS Processing**: SSL certificate application and automatic redirection possible
- **Static Files**: Fast serving by Nginx
- **Load Balancing**: Distribution across multiple Node.js servers possible

---

**In short, the structure where Nginx is placed before the Node.js server and Nginx receives all external requests to deliver them to Node.js is the standard!**

## User Traffic Flow

Very good question!
Below is a step-by-step diagram of the overall flow: **User → Frontend (React) → Backend (Node.js).**

---

## Overall Flow Diagram

```
[Internet User]
        │
   (Port 80/443)
        │
   [ Nginx Server ]
      │        │
      │        └─> [ Node.js(Express) API Server ] (Port 8080)
      └─> [ Static Files (React build) ]
```

---

## 1. User Access

- **User** accesses `http://yourdomain.com` from browser
- Nginx receives the request at port 80 (HTTP) or 443 (HTTPS)

---

## 2. Nginx Processing

- **Nginx** analyzes the request:
  - Request starting with `/api/` → Proxy to Node.js (Express)
  - Other requests → Respond with React build results (static files)

---

## 3. Frontend (React) Processing

- **React App** is loaded in the browser
- **React Router** renders appropriate page according to URL
- If **API call** is needed, send request to backend

---

## 4. Backend (Node.js) Processing

- **Node.js (Express)** receives the API request
- Process **DB lookup**, **business logic**, **authentication**, etc.
- Return **response** in JSON format

---

## 5. Response Delivery

- **Node.js** → **Nginx** → Deliver response to **User**
- **React App** receives response and updates UI

---

## 6. Practical Example

### 1) User accesses login page

- Access `http://yourdomain.com/login`
- Nginx responds with React build results (`index.html`)
- React App renders login page

### 2) User attempts login

- React App calls `/api/login` API
- Nginx proxies request to Node.js
- Node.js returns JWT token after auth processing
- React App stores token and redirects to main page

### 3) User looks up post list

- React App calls `/api/posts` API
- Nginx proxies request to Node.js
- Node.js returns post list after DB lookup
- React App renders post list

---

## 7. Advantages

- **Security**: Node.js server is not directly exposed to the outside
- **Performance**: Static files are served quickly by Nginx
- **HTTPS**: SSL certificate can be applied in Nginx
- **Caching/Compression**: Performance optimization possible through Nginx setup

---

## 8. Conclusion

- **Nginx** acts as a **central gateway** connecting Frontend (React) and Backend (Node.js)
- **Frontend** is served directly by Nginx as static files
- **Backend** has only API requests proxied by Nginx

## proxy_set_header X-Real-IP $remote_addr; # Deliver user IP

Very good question!
**`proxy_set_header X-Real-IP $remote_addr;`** is used to deliver the **actual IP address of the user** to the Node.js server.

---

## 1. Why is it needed?

### 1) IP-based features

- **Log recording**: Track by leaving user IP in logs
- **Access restriction**: Allow/Block access only from specific IPs
- **Location-based services**: Provide region-specific services based on IP

### 2) Problem situation

- When **Nginx** receives the request in the middle, Node.js recognizes that the request came from **Nginx**
- Node.js cannot know the actual IP of the user (`$remote_addr`)
- → Deliver user IP via **`X-Real-IP` header**

---

## 2. Practical Example

### 1) Nginx Setup

```nginx
location /api/ {
    proxy_pass http://localhost:8080;
    proxy_set_header X-Real-IP $remote_addr;  # Deliver user IP
}
```

### 2) Confirm IP in Node.js (Express)

```javascript
app.get("/api/users", (req, res) => {
  const userIP = req.headers["x-real-ip"]; // Confirm user IP
  console.log("User IP:", userIP);
  // ... rest of the code
});
```

---

## 3. Advantages

- **Accurate logging**: Record user IP accurately
- **Security**: IP-based access restriction possible
- **Analysis**: Utilize for user behavior analysis

---

## 4. Conclusion

- **`X-Real-IP` header** delivers the actual user IP to Node.js
- Essential for **IP-based features** (log, access restriction, location-based services, etc.)

---

## 📝 Logging System Guide

This section explains the structured logging system using Winston and log file management.

---

## 🔧 Logging Configuration

### **1. Winston Logger Setup**

```javascript
// src/config/logger.js
const winston = require("winston");
const path = require("path");

const logDir = "/var/log/app/board-service/nodejs";

const logger = winston.createLogger({
  level: "info",
  format: winston.format.combine(
    winston.format.timestamp({
      format: "YYYY-MM-DD HH:mm:ss",
    }),
    winston.format.errors({ stack: true }),
    winston.format.json(),
  ),
  defaultMeta: { service: "board-service-backend" },
  transports: [
    new winston.transports.File({
      filename: path.join(logDir, "error.log"),
      level: "error",
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    new winston.transports.File({
      filename: path.join(logDir, "combined.log"),
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    new winston.transports.File({
      filename: path.join(logDir, "access.log"),
      level: "info",
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
  ],
});
```

### **2. Log File Structure**

```
/var/log/app/board-service/nodejs/
├── access.log      # Information level logs (HTTP requests, server status, etc.)
├── error.log       # Error level logs (errors, exceptions, etc.)
├── combined.log    # Integration of all level logs
└── .gitkeep        # File for Git tracking
```

---

## 📊 Log Levels and Format

### **Log Levels**

- **error**: Error and exception situations
- **warn**: Warning situations
- **info**: General information (HTTP requests, server status, etc.)
- **debug**: Debugging information (only in development environment)

### **Log Format Example**

```json
{
  "level": "info",
  "message": "GET /health",
  "service": "board-service-backend",
  "timestamp": "2025-08-25 12:24:04",
  "method": "GET",
  "url": "/health",
  "ip": "127.0.0.1",
  "userAgent": "curl/8.7.1"
}
```

---

## 🚀 Logging Usage

### **1. Basic Logging**

```javascript
const logger = require("./config/logger");

// Info log
logger.info("Server started successfully");

// Error log
logger.error("Database connection failed", { error: err.message });

// Warning log
logger.warn("High memory usage detected", { memory: process.memoryUsage() });
```

### **2. HTTP Request Logging**

```javascript
// HTTP request logging using Morgan
app.use(morgan("combined", { stream: logger.stream }));

// Custom request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.url}`, {
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get("User-Agent"),
  });
  next();
});
```

### **3. Error Logging**

```javascript
// Error processing middleware
app.use((err, req, res, next) => {
  logger.error("Unhandled error:", {
    error: err.message,
    stack: err.stack,
    method: req.method,
    url: req.url,
    ip: req.ip,
  });
  res.status(500).json({ message: "Something went wrong!" });
});
```

---

## 📁 Log File Management

### **1. Log Rotation**

- **Max file size**: 5MB
- **Max file count**: 5
- **Automatic rotation**: Based on size

### **2. Create Log Directory**

```bash
# Create log directory
sudo mkdir -p /var/log/app/board-service/nodejs

# Setup permissions
sudo chown -R $(whoami):$(id -gn) /var/log/app/board-service/nodejs
sudo chmod 777 /var/log/app/board-service/nodejs
```

### **3. Log Monitoring**

```bash
# Confirm real-time logs
tail -f /var/log/app/board-service/nodejs/access.log
tail -f /var/log/app/board-service/nodejs/error.log

# Confirm log line count
wc -l /var/log/app/board-service/nodejs/*.log

# Search specific patterns
grep "error" /var/log/app/board-service/nodejs/combined.log
```

---

## 🐳 Docker Logging

### **1. Docker Compose Configuration**

```yaml
services:
  backend:
    image: dnwn7166/board-backend:latest
    ports:
      - "8080:8080"
    volumes:
      - /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs
    env_file:
      - ./backend/.env
```

### **2. Dockerfile Log Directory**

```dockerfile
# Create log directory and setup permissions
RUN mkdir -p /var/log/app/board-service/nodejs && \
    chown -R nodejs:nodejs /var/log/app/board-service/nodejs && \
    chmod -R 755 /var/log/app/board-service/nodejs
```

### **3. Confirm Container Logs**

```bash
# Confirm container logs
docker logs board-backend

# Confirm real-time logs
docker logs -f board-backend

# Confirm host log files
ls -la /var/log/app/board-service/nodejs/
```

---

## 🔍 Log Analysis and Monitoring

### **1. Log Analysis Tools**

```bash
# HTTP request statistics
grep "GET\|POST\|PUT\|DELETE" /var/log/app/board-service/nodejs/access.log | wc -l

# Error occurrence frequency
grep "error" /var/log/app/board-service/nodejs/error.log | wc -l

# Access records for specific IP
grep "127.0.0.1" /var/log/app/board-service/nodejs/access.log
```

### **2. Log Backup**

```bash
# Log backup
cp -r /var/log/app/board-service/nodejs /backup/nodejs-logs-$(date +%Y%m%d)

# Log compression
tar -czf /backup/nodejs-logs-$(date +%Y%m%d).tar.gz /var/log/app/board-service/nodejs/
```

---

## 🎯 Logging Best Practices

### **1. Log Message Writing**

- **Clear and specific**: "Database connection failed" vs "Error occurred"
- **Include context**: Request info, user ID, session ID, etc.
- **Consistent format**: Log messages with the same pattern

### **2. Performance Considerations**

- **Asynchronous logging**: Winston's default setup
- **Adjust log levels**: Deactivate debug level in production
- **Limit log file size**: Manage disk space

### **3. Security Considerations**

- **Exclude sensitive info**: Password, token, etc.
- **Log access permissions**: Setup appropriate file permissions
- **Log retention period**: Organize logs as needed

---

## 🏗️ Docker Image Management Guide

This section explains the overall process of building Docker images, creating tags, pushing to Docker Hub, and executing them.

---

## 📝 Docker Logging Setup

### **1. Prepare Log Directory**

```bash
# Create log directory on host system
sudo mkdir -p /var/log/app/board-service/nodejs

# Setup permissions
sudo chown -R $(whoami):$(id -gn) /var/log/app/board-service/nodejs
sudo chmod 777 /var/log/app/board-service/nodejs
```

### **2. Docker Compose Logging Configuration**

```yaml
# docker-compose.yml
services:
  backend:
    image: dnwn7166/board-backend:latest
    ports:
      - "8080:8080"
    volumes:
      - /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs
    env_file:
      - ./backend/.env
```

### **3. Docker Run Logging Configuration**

```bash
# Basic execution (including logging)
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  your-username/board-backend:latest

# Use environment variable file (including logging)
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  --env-file ./backend/.env \
  your-username/board-backend:latest
```

### **4. Confirm Log Files**

```bash
# Monitor real-time logs
tail -f /var/log/app/board-service/nodejs/access.log
tail -f /var/log/app/board-service/nodejs/error.log
tail -f /var/log/app/board-service/nodejs/combined.log

# Log statistics
wc -l /var/log/app/board-service/nodejs/*.log

# Search specific patterns
grep "error" /var/log/app/board-service/nodejs/error.log
grep "GET\|POST" /var/log/app/board-service/nodejs/access.log
```

---

## 🔨 1. Build Docker Image

### **Build Backend Image**

```bash
# Execute in project root directory
docker build -t board-backend:latest ./backend

# Or execute in backend directory
cd backend
docker build -t board-backend:latest .
```

### **Build Process Description**

1. Use **Node.js 18 Alpine** base image
2. **Install dependencies** (`npm ci --only=production`)
3. **Create security user** (`nodejs` non-root user)
4. **Copy source code** and setup permissions
5. Setup **Health Check** script
6. Create **final image**

### **Confirm Build**

```bash
# Confirm image list
docker images | grep board-backend

# Confirm image detail info
docker inspect board-backend:latest
```

---

## 🏷️ 2. Create Docker Image Tag

### **Create Tag for Local Image**

```bash
# Basic tag
docker tag board-backend:latest board-backend:v1.0.0

# Tag with Docker Hub username
docker tag board-backend:latest your-username/board-backend:latest
docker tag board-backend:latest your-username/board-backend:v1.0.0

# Specific version tag
docker tag board-backend:latest your-username/board-backend:stable
```

### **Confirm Tags**

```bash
# Confirm all tags
docker images board-backend

# Confirm all tags of a specific image
docker images your-username/board-backend
```

### **Tag Management Tips**

- **latest**: Latest stable version
- **v1.0.0**: Semantic versioning
- **stable**: Stable version
- **dev**: Development/test version

---

## 🚀 3. Push Image to Docker Hub

### **Docker Hub Login**

```bash
# Login with Docker Hub account
docker login

# Enter username and password
Username: your-username
Password: ********
```

### **Push Image**

```bash
# Push latest version
docker push your-username/board-backend:latest

# Push specific version
docker push your-username/board-backend:v1.0.0

# Push all tags
docker push your-username/board-backend --all-tags
```

### **Confirm Push**

```bash
# Confirm image in Docker Hub
docker search your-username/board-backend

# Confirm remote image info
docker pull your-username/board-backend:latest
```

---

## 📥 4. Pull and Run Docker Image

### **Pull Image**

```bash
# Pull latest version
docker pull your-username/board-backend:latest

# Pull specific version
docker pull your-username/board-backend:v1.0.0

# Confirm images
docker images your-username/board-backend
```

### **Run Container**

#### **Basic Execution**

```bash
# Run on port 8080 (including logging)
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  your-username/board-backend:latest
```

#### **Use Environment Variable File (Recommended)**

```bash
# Use .env file (including logging)
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  --env-file ./backend/.env \
  your-username/board-backend:latest
```

#### **Run by Environment**

```bash
# Development environment (including logging)
docker run -d --name board-backend-dev -p 8081:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  -e NODE_ENV=development \
  -e PORT=8080 \
  your-username/board-backend:latest

# Production environment (including logging)
docker run -d --name board-backend-prod -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  -e NODE_ENV=production \
  -e PORT=8080 \
  --env-file ./backend/.env \
  your-username/board-backend:latest
```

---

## 🔄 Overall Workflow Example

### **1. Development → Build → Deployment Process**

```bash
# 1. Build image after code modification
docker build -t board-backend:latest ./backend

# 2. Tag for Docker Hub
docker tag board-backend:latest your-username/board-backend:latest

# 3. Push to Docker Hub
docker push your-username/board-backend:latest

# 4. Pull on production server
docker pull your-username/board-backend:latest

# 5. Run new container (including logging)
docker stop board-backend-prod
docker rm board-backend-prod
docker run -d --name board-backend-prod -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  --env-file ./backend/.env \
  your-username/board-backend:latest
```

### **2. Version Management Workflow**

```bash
# 1. Build new version
docker build -t board-backend:v2.0.0 ./backend

# 2. Create multiple tags
docker tag board-backend:v2.0.0 your-username/board-backend:v2.0.0
docker tag board-backend:v2.0.0 your-username/board-backend:latest

# 3. Push all tags
docker push your-username/board-backend:v2.0.0
docker push your-username/board-backend:latest

# 4. Rollback preparation (Maintain previous version)
docker tag your-username/board-backend:v1.0.0 your-username/board-backend:stable
```

---

## 🐛 Logging Related Problem Solving

### **If log file is not created**

```bash
# 1. Confirm log directory permissions
ls -la /var/log/app/board-service/nodejs/

# 2. Fix permissions
sudo chmod 777 /var/log/app/board-service/nodejs

# 3. Confirm and fix ownership
sudo chown -R $(whoami):$(id -gn) /var/log/app/board-service/nodejs

# 4. Confirm log directory inside container
docker exec board-backend ls -la /var/log/app/board-service/nodejs/
```

### **Log volume mount issue**

```bash
# 1. Confirm volume mount status
docker inspect board-backend | grep -A 10 "Mounts"

# 2. Restart container (including volume mount)
docker stop board-backend
docker rm board-backend
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  your-username/board-backend:latest

# 3. Upon using Docker Compose
docker compose down
docker compose up -d
```

### **Log file size issue**

```bash
# 1. Confirm log file size
du -h /var/log/app/board-service/nodejs/*.log

# 2. Confirm log file rotation
ls -la /var/log/app/board-service/nodejs/

# 3. Cleanup old log files
find /var/log/app/board-service/nodejs/ -name "*.log" -mtime +30 -delete
```

---

## 🐛 General Problem Solving

### **Build failure**

```bash
# Confirm build context
docker build --no-cache -t board-backend:latest ./backend

# Confirm detailed build logs
docker build --progress=plain -t board-backend:latest ./backend
```

### **Push failure**

```bash
# Confirm Docker Hub login status
docker login

# Confirm image tags
docker images your-username/board-backend

# Confirm permissions
docker push your-username/board-backend:latest
```

### **Execution failure**

```bash
# Confirm container logs
docker logs board-backend

# Confirm port conflict
lsof -i :8080

# Use different port (including logging)
docker run -d --name board-backend -p 8081:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  your-username/board-backend:latest
```

### **Health Check failure**

```bash
# Confirm Health Check status
docker inspect board-backend | grep -A 10 "Health"

# Manual Health Check
docker exec board-backend node healthcheck.js

# Confirm environment variables
docker exec board-backend env | grep PORT
```

---

## 📊 Image Management Commands

### **Clean Up Images**

```bash
# Delete unused images
docker image prune

# Delete all unused images
docker image prune -a

# Delete specific image
docker rmi board-backend:latest
docker rmi your-username/board-backend:latest
```

### **Confirm Disk Usage**

```bash
# Confirm Docker usage
docker system df

# Confirm detailed usage
docker system df -v
```

---

## 🎯 Best Practices

### **Tag Strategy**

- **latest**: Always the latest stable version
- **vX.Y.Z**: Semantic versioning
- **stable**: Production stable version
- **dev**: Development/test version

### **Security**

- **Non-root user**: Run as `nodejs` user
- **Minimum permissions**: Copy only required files
- **Environment variables**: Manage sensitive info via `.env`
- **Regular updates**: Base image security patches

### **Performance**

- **Alpine Linux**: Light base image
- **Production dependencies**: Exclude devDependencies
- **Health Check**: Automatic status monitoring
- **Layer optimization**: Efficient build structure

### **Logging**

- **Structured logs**: JSON format for easy search and analysis
- **Log rotation**: Automatic file size limit and backup
- **Volume mount**: Persistent log storage on host system
- **Log levels**: Appropriate log levels per environment

---

## 📚 Docker Logging Command Summary

### **Basic Execution (including logging)**

```bash
# Run single container
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  your-username/board-backend:latest

# Use environment variable file
docker run -d --name board-backend -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  --env-file ./backend/.env \
  your-username/board-backend:latest
```

### **Development/Production Environment**

```bash
# Development environment
docker run -d --name board-backend-dev -p 8081:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  -e NODE_ENV=development \
  your-username/board-backend:latest

# Production environment
docker run -d --name board-backend-prod -p 8080:8080 \
  -v /var/log/app/board-service/nodejs:/var/log/app/board-service/nodejs \
  -e NODE_ENV=production \
  --env-file ./backend/.env \
  your-username/board-backend:latest
```

### **Using Docker Compose**

```bash
# Start service
docker compose up -d

# Restart service
docker compose restart backend

# Stop service
docker compose down
```

### **Log Monitoring**

```bash
# Container logs
docker logs -f board-backend

# Host log files
tail -f /var/log/app/board-service/nodejs/access.log
tail -f /var/log/app/board-service/nodejs/error.log
tail -f /var/log/app/board-service/nodejs/combined.log
```

---

## 🎯 Conclusion

Containerizing the Node.js backend using Docker:

- ✅ **Consistent environment**: Unification of development/staging/production environments
- ✅ **Fast deployment**: Image-based deployment for fast rollout
- ✅ **Scalability**: Horizontal expansion with container orchestration
- ✅ **Maintainability**: Easy management based on configuration files
- ✅ **Security**: Strengthened security with isolated environments
- ✅ **Logging**: Easy monitoring and debugging with structured logging

By following this guide, you can build Docker containers that can be operated stably in a production environment.

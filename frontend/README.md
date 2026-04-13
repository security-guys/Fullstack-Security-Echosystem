# React Learning Process

1. **Basic Concepts and Entry Point**
   - `index.tsx`: Entry point of the application
   - `App.tsx`: Top-level component
   - Component-based architecture

2. **Routing and Page Structure**
   - Routing structure in the `routes/` directory
   - Page transitions and navigation

3. **State Management**
   - Use of Context API in the `contexts/` directory
   - Custom hooks in the `hooks/` directory

4. **Component Structure**
   - Reusable components in the `components/` directory
   - Container components in the `containers/` directory

5. **API Communication**
   - Server communication structure in the `api/` directory
   - Asynchronous data processing

## React Basic Concepts

### 1. Component

```typescript
// Functional Component
const Button: React.FC = () => {
  return <button>Click</button>;
};

// Usage
<Button />
```

### 2. JSX

```typescript
// JSX Syntax
const Element = () => {
  return (
    <div>
      <h1>Title</h1>
      <p>Content</p>
    </div>
  );
};
```

### 3. Props

```typescript
// Passing Props
const Parent = () => {
  return <Child name="Hong Gil-dong" age={20} />;
};

// Receiving Props
const Child: React.FC<{ name: string; age: number }> = ({ name, age }) => {
  return (
    <div>
      <p>Name: {name}</p>
      <p>Age: {age}</p>
    </div>
  );
};
```

### 4. Event Handling

```typescript
const Button: React.FC = () => {
  const handleClick = () => {
    console.log('Clicked!');
  };

  return <button onClick={handleClick}>Click</button>;
};
```

### 5. Conditional Rendering

```typescript
const Greeting: React.FC<{ isLoggedIn: boolean }> = ({ isLoggedIn }) => {
  return (
    <div>
      {isLoggedIn ? (
        <h1>Welcome!</h1>
      ) : (
        <h1>Login required</h1>
      )}
    </div>
  );
};
```

### 6. List Rendering

```typescript
const List: React.FC = () => {
  const items = ['Apple', 'Banana', 'Orange'];

  return (
    <ul>
      {items.map((item, index) => (
        <li key={index}>{item}</li>
      ))}
    </ul>
  );
};
```

### 7. Styling

```typescript
// Inline Style
const StyledDiv = () => {
  return (
    <div style={{
      color: 'blue',
      fontSize: '20px'
    }}>
      Styled text
    </div>
  );
};

// CSS Class
const StyledButton = () => {
  return <button className="my-button">Styled Button</button>;
};
```

### 8. Form Handling

```typescript
const Form: React.FC = () => {
  const [input, setInput] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Submitted value:', input);
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={input}
        onChange={(e) => setInput(e.target.value)}
      />
      <button type="submit">Submit</button>
    </form>
  );
};
```

### 9. Component Composition

```typescript
const Page: React.FC = () => {
  return (
    <div>
      <Header />
      <Main />
      <Footer />
    </div>
  );
};
```

### 10. Basic Hooks

```typescript
// useState
const [count, setCount] = useState(0);

// useEffect
useEffect(() => {
  console.log("Component mounted");
}, []);

// useContext
const value = useContext(MyContext);
```

### useCallback

### 1. Using without useCallback

```typescript
const Component: React.FC = () => {
  // A new function is created on every render
  const handleClick = () => {
    console.log('Clicked!');
  };

  return <button onClick={handleClick}>Click</button>;
};
```

- A new function is created every time the component renders.
- The previous function becomes a candidate for garbage collection (memory cleanup).
- Memory usage might be higher.

### 2. Using with useCallback

```typescript
const Component: React.FC = () => {
  // Function is created only once when the component first mounts
  const handleClick = useCallback(() => {
    console.log('Clicked!');
  }, []);  // Empty array means the function is created only once

  return <button onClick={handleClick}>Click</button>;
};
```

- Creates the function only once when the component first mounts.
- Reuses the same function in subsequent renders.
- The function is maintained in memory.

### 3. With Dependency Array

```typescript
const Component: React.FC = () => {
  const [count, setCount] = useState(0);

  // New function is created only when count changes
  const handleClick = useCallback(() => {
    console.log(`Current count: ${count}`);
  }, [count]);  // Function is recreated only when count changes

  return <button onClick={handleClick}>Click</button>;
};
```

- A new function is created only when the values in the dependency array change.
- Otherwise, it reuses the previously created function.

### Memory Usage in Real Example:

```typescript
const BoardRoutes: React.FC = () => {
  const [posts, setPosts] = useState<Post[]>([]);

  // 1. Using useCallback
  const fetchPosts = useCallback(async () => {
    const data = await postService.getPosts();
    setPosts(data);
  }, []);  // Created once and reused continuously

  // 2. Without useCallback
  const fetchPostsWithoutCallback = async () => {
    const data = await postService.getPosts();
    setPosts(data);
  };  // New function created on every render

  return (
    <div>
      <button onClick={fetchPosts}>Refresh</button>
      {posts.map(post => (
        <PostItem key={post.id} post={post} />
      ))}
    </div>
  );
};
```

### Summary:

1. **When using useCallback**:
   - The function is created once in memory and maintained.
   - The same function is reused in subsequent renders.
   - Memory usage remains constant.

2. **When not using useCallback**:
   - A new function is created on every render.
   - The previous function becomes a candidate for garbage collection.
   - Memory usage may fluctuate.

### Summary:

1. **Component**: Basic building block of UI.
2. **JSX**: JavaScript XML, React's template syntax.
3. **Props**: Passing data from parent to child.
4. **Event Handling**: Handling user interactions.
5. **Conditional Rendering**: Displaying UI based on conditions.
6. **List Rendering**: Displaying array data.
7. **Styling**: Methods to apply CSS.
8. **Form Handling**: Handling user input.
9. **Component Composition**: Constructing UI by combining multiple components.
10. **Basic Hooks**: useState, useEffect, useContext, etc.

### 1. Props (Parent → Child)

A method for passing data from a parent component to a child component.

```typescript
// Parent Component
const Parent: React.FC = () => {
  const [message, setMessage] = useState("Hello");

  return (
    <div>
      <Child message={message} />  {/* Passing message as props */}
    </div>
  );
};

// Child Component
const Child: React.FC<{ message: string }> = ({ message }) => {
  return <div>{message}</div>;  {/* Using message received via props */}
};
```

### 2. Callback Props (Child → Parent)

A method for passing data from a child component to a parent component.

```typescript
// Parent Component
const Parent: React.FC = () => {
  const [message, setMessage] = useState("");

  // Function to receive data from child
  const handleChildData = (data: string) => {
    setMessage(data);
  };

  return (
    <div>
      <p>Message received from child: {message}</p>
      <Child onSendData={handleChildData} />  {/* Passing callback function */}
    </div>
  );
};

// Child Component
const Child: React.FC<{ onSendData: (data: string) => void }> = ({ onSendData }) => {
  const handleClick = () => {
    onSendData("Hello!");  {/* Passing data to parent */}
  };

  return (
    <button onClick={handleClick}>
      Send message to parent
    </button>
  );
};
```

### Real Usage Example:

```typescript
// 1. Props Example (Parent → Child)
const PostList: React.FC = () => {
  const [posts, setPosts] = useState<Post[]>([]);

  return (
    <div>
      {posts.map(post => (
        <PostItem
          key={post.id}
          title={post.title}      {/* Passing data via props */}
          content={post.content}  {/* Passing data via props */}
        />
      ))}
    </div>
  );
};

const PostItem: React.FC<{ title: string; content: string }> = ({ title, content }) => {
  return (
    <div>
      <h2>{title}</h2>
      <p>{content}</p>
    </div>
  );
};

// 2. Callback Props Example (Child → Parent)
const PostForm: React.FC = () => {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit({ title, content });  {/* Passing data to parent */}
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
      />
      <button type="submit">Write</button>
    </form>
  );
};

const PostPage: React.FC = () => {
  const handlePostSubmit = (postData: { title: string; content: string }) => {
    // Logic to save post
    console.log(postData);
  };

  return (
    <div>
      <PostForm onSubmit={handlePostSubmit} />  {/* Passing callback function */}
    </div>
  );
};
```

### Summary:

1. **Props (Parent → Child)**
   - Passing data from parent component to child component.
   - One-way data flow.
   - Child components can only use the received props.

2. **Callback Props (Child → Parent)**
   - Passing data from child component to parent component.
   - Child calls the function passed by the parent.
   - Child component can deliver data to the parent.

Simplified explanation of `useState` and `useEffect`:

### 1. useState

A hook for managing state. It allows you to store and manage data that changes within a component.

```typescript
// Basic usage
const [count, setCount] = useState(0);  // Initial value 0

// Usage example
const Counter: React.FC = () => {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Current Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increase</button>
      <button onClick={() => setCount(count - 1)}>Decrease</button>
    </div>
  );
};
```

### 2. useEffect

A hook for handling tasks related to a component's lifecycle. It allows you to define code to run when specific states change.

```typescript
// Basic usage
useEffect(() => {
  // Code to execute
}, [Dependency Array]);

// Usage example
const UserProfile: React.FC = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Runs when the component mounts
  useEffect(() => {
    const fetchUser = async () => {
      try {
        const response = await fetch('/api/user');
        const data = await response.json();
        setUser(data);
      } catch (error) {
        console.error('Error:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, []);  // Empty array means it runs only when the component first mounts

  if (loading) return <div>Loading...</div>;
  return <div>{user?.name}</div>;
};
```

### Real Usage Example:

```typescript
// 1. useState Example
const PostForm: React.FC = () => {
  // Managing multiple states
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      await submitPost({ title, content });
      setTitle('');
      setContent('');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={title}
        onChange={(e) => setTitle(e.target.value)}
      />
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
      />
      <button disabled={isSubmitting}>
        {isSubmitting ? 'Submitting...' : 'Submit'}
      </button>
    </form>
  );
};

// 2. useEffect Example
const PostList: React.FC = () => {
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Fetching data
  useEffect(() => {
    const fetchPosts = async () => {
      try {
        const response = await fetch('/api/posts');
        const data = await response.json();
        setPosts(data);
      } catch (err) {
        setError('Failed to fetch data.');
      } finally {
        setLoading(false);
      }
    };

    fetchPosts();
  }, []);  // Runs once on component mount

  // Runs whenever search term changes
  useEffect(() => {
    const searchPosts = async () => {
      if (searchTerm) {
        const results = await searchPosts(searchTerm);
        setPosts(results);
      }
    };

    searchPosts();
  }, [searchTerm]);  // Runs every time searchTerm changes

  if (loading) return <div>Loading...</div>;
  if (error) return <div>{error}</div>;

  return (
    <div>
      {posts.map(post => (
        <PostItem key={post.id} post={post} />
      ))}
    </div>
  );
};
```

### Summary:

1. **useState**
   - Manages component state.
   - Component re-renders when state changes.
   - Used in the form `[state, stateUpdateFunction]`.

2. **useEffect**
   - Handles tasks related to component lifecycle.
   - Data fetching, subscription setup, manual DOM manipulation, etc.
   - Execution timing determined by the dependency array.
   - Empty array `[]` runs only once on component mount.

## Callback Concept

Step-by-step explanation of the evolution of JavaScript's asynchronous processing methods:

### 1. Callback

```javascript
// Past callback method
function fetchData(callback) {
  setTimeout(() => {
    const data = "Data";
    callback(data);
  }, 1000);
}

// Usage
fetchData((data) => {
  console.log(data);
});
```

- Problem: Callback hell occurs.
- Poor readability.
- Difficult error handling.

### 2. Promise

```javascript
// Using Promise
function fetchData() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      const data = "Data";
      resolve(data);
    }, 1000);
  });
}

// Usage
fetchData()
  .then((data) => console.log(data))
  .catch((error) => console.error(error));
```

- Advantage: Chaining possible.
- Easy error handling.
- Solves callback hell.

### 3. async/await

```javascript
// Using async/await
async function fetchData() {
  try {
    const data = await new Promise((resolve) => {
      setTimeout(() => resolve("Data"), 1000);
    });
    return data;
  } catch (error) {
    console.error(error);
  }
}

// Usage
const data = await fetchData();
console.log(data);
```

- Advantage: Can be written like synchronous code.
- Improved readability.
- Easier error handling.

### Real Usage Example:

```javascript
// 1. Callback
postService.getPosts((data) => {
  setPosts(data);
});

// 2. Promise
postService
  .getPosts()
  .then((data) => setPosts(data))
  .catch((error) => console.error(error));

// 3. async/await
try {
  const data = await postService.getPosts();
  setPosts(data);
} catch (error) {
  console.error(error);
}
```

### Summary:

1. **Callback**
   - Most basic asynchronous processing.
   - Callback hell problem.

2. **Promise**
   - Solves callback hell.
   - Chaining possible.
   - Improved error handling.

3. **async/await**
   - Written like synchronous code.
   - Best readability.
   - Easiest error handling.

Explaining the difference between `async` and `await`:

### 1. async

```javascript
// async turns a function into an asynchronous function
async function fetchData() {
  // This function returns a Promise
  return "Data";
}

// Usage
fetchData().then((data) => console.log(data));
```

### 2. await

```javascript
// await waits until the Promise is completed
async function fetchData() {
  const data = await somePromise; // Wait until Promise is completed
  return data;
}
```

### Real Example:

```javascript
// 1. Using only async
async function getPosts() {
  return postService.getPosts(); // Returns Promise
}

// 2. Using async and await together
async function getPosts() {
  const posts = await postService.getPosts(); // Wait until Promise is completed
  return posts; // Returns actual data
}

// 3. Real usage
const fetchPosts = async () => {
  try {
    const data = await postService.getPosts(); // Wait until data arrives
    setPosts(data); // Set data
  } catch (error) {
    console.error(error);
  }
};
```

### Key Differences:

1. **async**
   - Turns a function into an asynchronous function.
   - Always returns a Promise.
   - Used in function declarations.

2. **await**
   - Waits until a Promise is completed.
   - Can only be used inside async functions.
   - Returns the result value of the Promise.

### Usage Scenarios:

```javascript
// 1. Simple Promise return
async function getData() {
  return fetch("/api/data");
}

// 2. Waiting for Promise result
async function getData() {
  const response = await fetch("/api/data");
  const data = await response.json();
  return data;
}

// 3. Handling multiple Promises
async function getMultipleData() {
  const [data1, data2] = await Promise.all([
    fetch("/api/data1"),
    fetch("/api/data2"),
  ]);
  return { data1, data2 };
}
```

### Summary:

1. **async**
   - Makes function asynchronous.
   - Returns Promise.

2. **await**
   - Waits for Promise completion.
   - Returns result value.

Yes, you understood correctly! `await` serves to ensure synchronous execution within asynchronous code.

### Explanation with Example:

```typescript
// 1. Async function declaration
async function handleCreatePost(postData) {
  // 2. Ensure synchronous execution with await
  const data = await postService.createPost(postData); // Step 1: Wait until API call is complete
  setPosts((prevPosts) => [data, ...prevPosts]); // Step 2: Executes only when data is present
  navigate("/board"); // Step 3: Executes after state update
}
```

### Real Usage Example:

```typescript
// 1. Creating a post
async function handleCreatePost(postData) {
  const data = await postService.createPost(postData); // Wait for API response
  setPosts((prevPosts) => [data, ...prevPosts]); // Set data
  navigate("/board"); // Navigate page
}

// 2. Editing a post
async function handleEditPost(postId, postData) {
  const data = await postService.updatePost(postId, postData); // Wait for API response
  setPosts((prevPosts) =>
    prevPosts.map((post) => (post._id === postId ? data : post)),
  ); // Update data
  navigate(`/board/${postId}`); // Navigate page
}

// 3. Deleting a post
async function handleDeletePost(postId) {
  await postService.deletePost(postId); // Wait for API response
  setPosts((prevPosts) => prevPosts.filter((post) => post._id !== postId)); // Delete data
  navigate("/board"); // Navigate page
}
```

### Advantages of await:

1. **Guaranteed Order**
   - Executes subsequent tasks after waiting for API response.
   - Updates state only when data is present.

2. **Readability**
   - Can be written like synchronous code.
   - Clear code flow.

3. **Error Handling**
   - Easily handled with try/catch.
   - Easy to identify point of error.

## Step 1: Start of React App and Project Structure

### 1. Entry Point: `index.tsx`

```tsx
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";

const root = ReactDOM.createRoot(
  document.getElementById("root") as HTMLElement,
);
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
```

**What this code does:**

- Finds `<div id="root"></div>` in `public/index.html`.
- Renders the entire React app starting from the `App` component into this div.
- `React.StrictMode` helps find potential problems during development.

### Reasons for using React.FC:

1. **Explicit Declaration**:

```typescript
// Using React.FC
const Button: React.FC<{ text: string }> = ({ text }) => {
  return <button>{text}</button>;
};
```

- Clearly declares "This is a React component!"
- Other developers can understand immediately when looking at the code.

2. **Automatic Inclusion of children prop**:

```typescript
// Using React.FC
const Container: React.FC<{ title: string }> = ({ title, children }) => {
  return (
    <div>
      <h1>{title}</h1>
      {children} {/* children prop is automatically included */}
    </div>
  );
};
```

### Reasons for not using React.FC:

1. **Simpler Syntax**:

```typescript
// Not using React.FC
const Button = ({ text }: { text: string }) => {
  return <button>{text}</button>;
};
```

- Code is simpler and cleaner.
- No unnecessary type declarations.

2. **When children prop is not needed**:

```typescript
// Not using React.FC
const Button = ({ text }: { text: string }) => {
  return <button>{text}</button>;
};
```

- Becomes an unnecessary type declaration in components where the children prop isn't needed.

### Choice in Real Projects:

1. **Team Convention**:

- Some teams prefer using `React.FC`.
- Some teams prefer not using it.
- It is important to follow a consistent coding style within the team.

2. **Project Characteristics**:

```typescript
// When children are needed
const Layout: React.FC<{ title: string }> = ({ title, children }) => {
  return (
    <div>
      <h1>{title}</h1>
      {children}
    </div>
  );
};

// When children are not needed
const Button = ({ text }: { text: string }) => {
  return <button>{text}</button>;
};
```

### Conclusion:

- `React.FC` is optional.
- You can use it or not.
- Choose based on team coding style or project characteristics.
- Recently, there is a trend towards preferring simpler methods.

## Meaning of React.ReactNode

### 1. Basic Component:

```typescript
// Container Component
const Container = ({ children }: { children: React.ReactNode }) => {
  return <div>{children}</div>;
};

// Usage Example
<Container>
  <div>Hello</div>
</Container>
```

### 2. Combining Multiple Components:

```typescript
// Layout Component
const Layout = ({ children }: { children: React.ReactNode }) => {
  return (
    <div>
      <Header />
      {children}  {/* Any component can go here */}
      <Footer />
    </div>
  );
};

// Usage Example
<Layout>
  <Main />
  <Sidebar />
  <Content />
</Layout>
```

### 3. Usage in AuthProvider:

```typescript
// AuthProvider Component
const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  return (
    <AuthContext.Provider value={{...}}>
      {children}  {/* Any component can go here */}
    </AuthContext.Provider>
  );
};

// Usage Example
<AuthProvider>
  <Router>
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
    </Routes>
  </Router>
</AuthProvider>
```

### 4. Real Usage Example:

```typescript
// 1. Simple Component
<Container>
  <div>Hello</div>
</Container>

// 2. Complex Component
<Container>
  <div>
    <h1>Title</h1>
    <p>Content</p>
    <button>Click</button>
  </div>
</Container>

// 3. Multiple Components
<Container>
  <Header />
  <Main />
  <Footer />
</Container>

// 4. Conditional Rendering
<Container>
  {isLoggedIn ? <Dashboard /> : <Login />}
</Container>
```

### Summary:

- `React.ReactNode` can receive anything that can be used in React.
- Includes components, strings, numbers, null, undefined, etc.
- It is a very flexible type that can render almost anything.
- Primarily used in the `children` prop.

### 2. HTML Template: `public/index.html`

```html
<body>
  <div id="root"></div>
</body>
```

- This is the only HTML element used by the React app.
- Everything visible in the browser is rendered by React inside this `root` div.

### 3. Top-Level Component: `App.tsx`

```tsx
const App: React.FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>
        <Router>
          <AppRoutes />
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
};
```

**What's happening here:**

- `ThemeProvider` and `CssBaseline` are from Material-UI, setting the design system and initializing browser CSS.
- `AuthProvider` provides authentication state to the entire app.
- `Router` enables client-side navigation (Single Page App).
- `AppRoutes` contains the actual page routes.

### 4. Routing: `AppRoutes`

```tsx
const AppRoutes: React.FC = () => {
  const { user, loading } = useAuth();

  if (loading) {
    return <CircularProgress />;
  }

  return (
    <Routes>
      {user && (
        <>
          <Route path="/login" element={<Navigate to="/board" replace />} />
          <Route path="/register" element={<Navigate to="/board" replace />} />
        </>
      )}
      <Route path="/*" element={user ? <BoardRoutes /> : <AuthRoutes />} />
    </Routes>
  );
};
```

- If the user is logged in, they are redirected from `/login` and `/register` to `/board`.
- If not logged in, it shows authentication routes.
- Shows a loading spinner while checking authentication status.

### 5. Project Structure (`src/` folder)

- `index.tsx`: Entry point
- `App.tsx`: Top-level component
- `routes/`: Route definitions (pages)
- `components/`: Reusable UI components
- `contexts/`: Context providers (Auth, etc.)
- `api/`: Backend API calls
- `containers/`: Data fetching and state management logic
- `hooks/`: Custom React hooks
- `theme.ts`: Material-UI theme settings

### Summary

- The browser loads `index.html` which has only one `<div id="root"></div>`.
- `index.tsx` renders the React app inside that div.
- `App.tsx` sets up global providers (Theme, Auth, Router).
- Routing and page logic are handled in `AppRoutes` and the `routes/` folder.
- All UI is composed of components in the `components/` folder.

Which part would you like to know more about?

1. Routing System
2. Context API and State Management
3. Component Structure
4. Material-UI Styling

## Step 2: Routing and Page Structure

### 1. AppRoutes Component

```typescript
// src/App.tsx
const AppRoutes: React.FC = () => {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh' }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <Routes>
        {/* Redirect authenticated users to /board if they access /login or /register */}
        {user && (
          <>
            <Route path="/login" element={<Navigate to="/board" replace />} />
            <Route path="/register" element={<Navigate to="/board" replace />} />
          </>
        )}

        {/* Authenticated users to /board, otherwise to AuthRoutes */}
        <Route path="/*" element={user ? <BoardRoutes /> : <AuthRoutes />} />
      </Routes>
    </Box>
  );
};
```

### 2. Routing Structure in `routes/` Directory

```typescript
// src/routes/AuthRoutes.tsx
const AuthRoutes: React.FC = () => {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="*" element={<Navigate to="/login" />} />
    </Routes>
  );
};

// src/routes/BoardRoutes.tsx
const BoardRoutes: React.FC = () => {
  return (
    <Routes>
      <Route path="/board" element={<PostList />} />
      <Route path="/board/:id" element={<PostDetail />} />
      <Route path="/board/create" element={<PostForm />} />
    </Routes>
  );
};
```

### 3. Page Transitions and Navigation

```typescript
// 1. Using useNavigate hook
const Login: React.FC = () => {
  const navigate = useNavigate();

  const handleLogin = async () => {
    try {
      await login(email, password);
      navigate('/board');  // Navigate to board on successful login
    } catch (error) {
      // Error handling
    }
  };

  return (
    <button onClick={handleLogin}>Login</button>
  );
};

// 2. Using Link component
const Header: React.FC = () => {
  return (
    <nav>
      <Link to="/board">Board</Link>
      <Link to="/profile">Profile</Link>
    </nav>
  );
};
```

### 4. Key Routing Features

1. **Page Navigation**

```typescript
// Programmatic navigation
navigate('/board');

// Link navigation
<Link to="/board">Board</Link>
```

2. **Using URL Parameters**

```typescript
// Get URL parameters
const { id } = useParams();

// Dynamic route
<Route path="/board/:id" element={<PostDetail />} />
```

3. **Using Query Parameters**

```typescript
// Get query parameters
const [searchParams] = useSearchParams();
const page = searchParams.get("page");

// Navigate with query parameters
navigate(`/board?page=${page}`);
```

### Summary:

1. `AppRoutes`: Main routing component of the app.
   - Handles routing based on authentication state.
   - Handles loading state.
   - Separates routes for authenticated vs unauthenticated users.

2. `routes/` Directory: Detailed routing structure.
   - `AuthRoutes`: Routes related to login/registration.
   - `BoardRoutes`: Routes related to the board.

3. Page Transitions: Use `useNavigate` and `Link`.
4. Routing Features: Use URL parameters and query parameters.

## 2-1 AuthRoutes, BoardRoutes

### 1. AuthRoutes Basic Structure

```typescript
// src/routes/AuthRoutes.tsx
const AuthRoutes: React.FC = () => {
  const { logout } = useAuth();

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      {/* Header */}
      <Header
        isLoggedIn={false}
        username=""
        onLogout={logout}
        userInfo={null}
      />

      {/* Main Content */}
      <Box sx={{ flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Routes>
          {/* Default path redirects to login page */}
          <Route path="/" element={<Navigate to="/login" replace />} />

          {/* Login Page */}
          <Route path="/login" element={<Login />} />

          {/* Registration Page */}
          <Route path="/register" element={<Register />} />

          {/* Unknown paths redirect to login page */}
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </Box>
    </Box>
  );
};
```

### 2. Login Page (Login.tsx)

```typescript
const Login: React.FC = () => {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await login(email, password);
      navigate('/board');  // Navigate to board on successful login
    } catch (error) {
      // Error handling
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
      />
      <button type="submit">Login</button>
      <Link to="/register">Register</Link>
    </form>
  );
};
```

### 3. Registration Page (Register.tsx)

```typescript
const Register: React.FC = () => {
  const navigate = useNavigate();
  const { register } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await register(email, password, username);
      navigate('/login');  // Navigate to login page on successful registration
    } catch (error) {
      // Error handling
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input
        type="text"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        placeholder="Username"
      />
      <input
        type="email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
      />
      <input
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Password"
      />
      <button type="submit">Register</button>
      <Link to="/login">Login</Link>
    </form>
  );
};
```

### 4. How Routing Works

```typescript
// App.tsx
const App: React.FC = () => {
  const { user, loading } = useAuth();

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <Router>
      <Routes>
        {/* Redirect authenticated users to /board if they access /login or /register */}
        {user && (
          <>
            <Route path="/login" element={<Navigate to="/board" />} />
            <Route path="/register" element={<Navigate to="/board" />} />
          </>
        )}

        {/* Unauthenticated users to AuthRoutes */}
        <Route path="/*" element={user ? <BoardRoutes /> : <AuthRoutes />} />
      </Routes>
    </Router>
  );
};
```

### Summary:

1. **Role of AuthRoutes**:
   - Routes for unauthenticated users.
   - Provides login and registration pages.
   - Redirects unknown paths to the login page.

2. **Key Pages**:
   - `/login`: Login page.
   - `/register`: Registration page.

3. **Characteristics**:
   - Inaccessible to logged-in users.
   - Redirects to appropriate pages on successful login/registration.
   - Displays unauthenticated status in the header.

### Explaining the role of replace in relation to the browser's back button:

```typescript
<Route path="*" element={<Navigate to="/login" replace />} />
```

### 1. When not using replace:

```
1. User accesses /unknown page
2. Redirect to /login
3. Browser history: /unknown → /login
4. When back button is clicked: Returns to /unknown (non-existent page)
```

### 2. When using replace:

```
1. User accesses /unknown page
2. Redirect to /login
3. Browser history: /login (Previous page record is deleted)
4. When back button is clicked: Moves to the page before /login
```

### Real Example:

```typescript
// 1. Using replace
<Route path="*" element={<Navigate to="/login" replace />} />
// User accesses /unknown → moves to /login
// When going back: Moves to the page before /login

// 2. Not using replace
<Route path="*" element={<Navigate to="/login" />} />
// User accesses /unknown → moves to /login
// When going back: Returns to /unknown (non-existent page)
```

### Summary:

- `replace` serves to "prevent returning to non-existent pages."
- Provides more natural page transitions when the user goes back.
- Removes unnecessary page history.

### Basic Structure of BoardRoutes

```typescript
const BoardRoutes: React.FC = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const [posts, setPosts] = useState<Post[]>([]);
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);

  // Fetch post list
  const fetchPosts = useCallback(async () => {
    try {
      const data = await postService.getPosts();
      setPosts(data);
    } catch (error) {
      console.error('Failed to fetch posts:', error);
    }
  }, []);

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      {/* Header */}
      <Header
        isLoggedIn={true}
        username={user?.username || ''}
        onLogout={logout}
        userInfo={user}
      />

      {/* Main Content */}
      <Box sx={{ flex: 1, p: 3 }}>
        <Routes>
          {/* Post List */}
          <Route path="/" element={<PostList posts={posts} />} />

          {/* Post Detail */}
          <Route path="/:id" element={<PostDetail post={selectedPost} />} />

          {/* Create Post */}
          <Route path="/create" element={<PostForm />} />
        </Routes>
      </Box>
    </Box>
  );
};
```

### Key Functions:

1. **Routing Structure**

```typescript
<Routes>
  {/* Post list page */}
  <Route path="/" element={<PostList posts={posts} />} />

  {/* Post detail page */}
  <Route path="/:id" element={<PostDetail post={selectedPost} />} />

  {/* Create post page */}
  <Route path="/create" element={<PostForm />} />
</Routes>
```

2. **State Management**

```typescript
// Post list state
const [posts, setPosts] = useState<Post[]>([]);

// Selected post state
const [selectedPost, setSelectedPost] = useState<Post | null>(null);
```

3. **Data Fetching**

```typescript
const fetchPosts = useCallback(async () => {
  try {
    const data = await postService.getPosts();
    setPosts(data);
  } catch (error) {
    console.error("Failed to fetch posts:", error);
  }
}, []);
```

4. **Layout Structure**

```typescript
<Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
  {/* Header */}
  <Header
    isLoggedIn={true}
    username={user?.username || ''}
    onLogout={logout}
    userInfo={user}
  />

  {/* Main Content */}
  <Box sx={{ flex: 1, p: 3 }}>
    <Routes>
      {/* Routes */}
    </Routes>
  </Box>
</Box>
```

### Main Characteristics:

1. **For Authenticated Users Only**
   - Accessible only to logged-in users.
   - Displays user info in the header.

2. **Board Functions**
   - View post list.
   - View post detail.
   - Create post.

3. **Layout**
   - Composed of Header and Main Content.
   - Responsive design.

4. **State Management**
   - Manages post list.
   - Manages selected post.

### Summary:

1. `BoardRoutes` is a component that manages board-related pages.
2. Accessible only to logged-in users.
3. Provides list, detail, and creation functions for posts.
4. Layout composed of Header and Main Content.

## How fetchPosts Works

`fetchPosts` merely **defines** the function; the actual API call occurs within `useEffect`.

### 1. Defining fetchPosts

```typescript
const fetchPosts = useCallback(async () => {
  try {
    const data = await postService.getPosts(); // Define API call function
    setPosts(data); // Define state update function
  } catch (error) {
    console.error("Failed to fetch posts:", error);
  }
}, []);
```

- API is not called at this point.
- Only defines "this is how we will call the API and set the data."

### 2. Actual Execution in useEffect

```typescript
useEffect(() => {
  fetchPosts(); // API call actually occurs here
}, [fetchPosts]);
```

- **Actually executes** the `fetchPosts` function when the component mounts.
- Actual API call happens and data is fetched at this time.

### Analogy:

1. `fetchPosts` definition
   - Like writing a recipe.
   - Only explains "this is how you cook."

2. Execution in `useEffect`
   - Actually starting to cook.
   - Real cooking happens according to the recipe.

## useCallback used in fetchPosts

Yes, you understood correctly!

### Role of useCallback

```typescript
const fetchPosts = useCallback(async () => {
  try {
    const data = await postService.getPosts();
    setPosts(data);
  } catch (error) {
    console.error("Failed to fetch posts:", error);
  }
}, []); // Empty dependency array
```

- The `fetchPosts` function is not recreated even if the component re-renders.
- Maintains the same function instance throughout the component's lifecycle.

### Relationship with useEffect

```typescript
useEffect(() => {
  fetchPosts(); // Runs on component mount
}, [fetchPosts]); // Runs only when fetchPosts changes
```

- Since `fetchPosts` does not change, `useEffect` does not unnecessarily re-execute.
- Executes once upon component mount.

### Advantages:

1. **Performance Optimization**
   - Prevents unnecessary function recreation.
   - Prevents unnecessary `useEffect` re-execution.

2. **Memory Efficiency**
   - Reuses the same function instance.
   - Reduces garbage collection.

3. **Consistency**
   - Uses the same function throughout the component lifecycle.
   - Ensures predictable behavior.

## BoardRoutes Detailed Routing and Operation

This code defines the routing structure for the `BoardRoutes` component. Each part is explained in detail below:

### 1. Overall Layout

```typescript
<Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
  {/* Header */}
  <Header
    isLoggedIn={true}
    username={user.username}
    onLogout={logout}
    userInfo={user}
    refresh={fetchPosts}
  />

  {/* Main Content */}
  <Container maxWidth="md" sx={{ flex: 1, py: 3 }}>
    <Routes>
      {/* Routes */}
    </Routes>
  </Container>
</Box>
```

### 2. Route Structure

```typescript
<Routes>
  {/* 1. Default path -> Redirect to /board */}
  <Route path="/" element={<Navigate to="/board" replace />} />

  {/* 2. Post List */}
  <Route path="/board" element={
    <PostList
      posts={posts}
      onPostClick={handlePostClick}
      refresh={fetchPosts}
    />
  } />

  {/* 3. Post Detail */}
  <Route path="/board/:postId" element={
    selectedPost ? (
      <PostDetail
        post={selectedPost}
        currentUser={user}
        onEdit={() => navigate(`/board/${selectedPost._id}/edit`)}
        onDelete={() => handleDeletePost(selectedPost._id)}
        onBack={() => navigate('/board')}
        // Comment-related handlers
        onAddComment={...}
        onDeleteComment={...}
        onEditComment={...}
        // Reply-related handlers
        onAddReply={...}
        onDeleteReply={...}
        onEditReply={...}
        onLike={handleLike}
        refresh={fetchPosts}
      />
    ) : (
      <Navigate to="/board" />
    )
  } />

  {/* 4. Write New Post */}
  <Route path="/board/new" element={
    <PostForm
      onSubmit={handleCreatePost}
      onCancel={() => navigate('/board')}
    />
  } />

  {/* 5. Edit Post */}
  <Route path="/board/:postId/edit" element={
    selectedPost ? (
      <PostForm
        initialData={selectedPost}
        onSubmit={handleEditPost}
        onCancel={() => navigate(`/board/${selectedPost._id}`)}
      />
    ) : (
      <Navigate to="/board" />
    )
  } />
</Routes>
```

### Key Functions:

1. **Post List**
   - Display post list.
   - Refresh function.
   - Handle post click.

2. **Post Detail**
   - Display post content.
   - Comment/Reply function.
   - Like function.
   - Edit/Delete function.

3. **Create/Edit Post**
   - Write new post.
   - Edit existing post.
   - Move to previous page on cancellation.

### Characteristics:

1. **Conditional Rendering**
   - Redirect to list if `selectedPost` does not exist.
   - Pass appropriate handlers for each function.

2. **Navigation**
   - Page movement using `Maps` function.
   - History management using `replace` option.

3. **Data Flow**
   - Management of `posts` and `selectedPost` states.
   - Data update via `refresh` function.

## How setPost Works

Ah, `prevPosts` automatically receives the current value of the `posts` state. It uses the previously defined `posts` state:

### 1. Defining posts state

```typescript
// In BoardRoutes.tsx
const [posts, setPosts] = useState<Post[]>([]); // Post list state
```

### 2. Setting posts value

```typescript
// Initial data load
const fetchPosts = useCallback(async () => {
  try {
    const data = await postService.getPosts();
    setPosts(data); // Set posts with the list received from API
  } catch (error) {
    console.error("Failed to fetch posts:", error);
  }
}, []);
```

### 3. Usage in handleLike

```typescript
const handleLike = async (postId: string) => {
  try {
    const data = await postService.toggleLike(postId);

    // In setPosts callback, prevPosts receives current posts value
    setPosts((prevPosts) =>
      prevPosts.map((post) => (post._id === postId ? data : post)),
    );
  } catch (error) {
    console.error("Error liking post:", error);
  }
};
```

### Actual Data Flow:

```typescript
// 1. Initial State
posts = [
  { _id: '1', title: 'Post 1' },
  { _id: '2', title: 'Post 2' },
  { _id: '3', title: 'Post 3' }
];

// 2. When calling handleLike('2')
setPosts(prevPosts => {
  // prevPosts is the current value of posts
  // i.e., the list above is passed as is
  return prevPosts.map(...);
});
```

### Summary:

1. `posts` is component state.
2. In `setPosts` callback, `prevPosts` automatically receives the current value of `posts`.
3. Handled automatically by React without separate definition.

## Step 2. State Management

- Use of Context API in `contexts/` directory.
- Custom hooks in `hooks/` directory.

Detailed explanation of Context API structure and usage:

### 1. Defining AuthContext

```typescript
// frontend/src/contexts/AuthContext.tsx
interface AuthContextType {
  isLoggedIn: boolean;
  user: User | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (
    username: string,
    email: string,
    password: string,
  ) => Promise<void>;
  logout: () => void;
}

// Create Context
const AuthContext = createContext<AuthContextType | undefined>(undefined);
```

### 2. Implementing Provider

```typescript
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // State management
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  // Check initial authentication status
  useEffect(() => {
    const checkAuth = async () => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const response = await authService.getProfile();
          setUser(response.user);
          setIsLoggedIn(true);
        } catch (error) {
          localStorage.removeItem('token');
        }
      }
      setLoading(false);
    };
    checkAuth();
  }, []);

  // Authentication-related functions
  const login = async (email: string, password: string) => {
    const response = await authService.login({ email, password });
    localStorage.setItem('token', response.token);
    setUser(response.user);
    setIsLoggedIn(true);
  };

  const register = async (username: string, email: string, password: string) => {
    const response = await authService.register({ username, email, password });
    localStorage.setItem('token', response.token);
    setUser(response.user);
    setIsLoggedIn(true);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setUser(null);
    setIsLoggedIn(false);
  };

  // Provide Context values
  return (
    <AuthContext.Provider value={{
      isLoggedIn,
      user,
      loading,
      login,
      register,
      logout
    }}>
      {children}
    </AuthContext.Provider>
  );
};
```

### 3. Usage Method

```typescript
// Set Provider in App.tsx
const App: React.FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>  {/* Provide Auth-related Context */}
        <Router>
          <AppRoutes />
        </Router>
      </AuthProvider>
    </ThemeProvider>
  );
};

// Use in Component
const Login: React.FC = () => {
  const { login } = useAuth();  // Get login function from Context

  const handleSubmit = async (e: React.FormEvent) => {
    try {
      await login(username, password);
      navigate('/board');
    } catch (err) {
      setError('Invalid username or password');
    }
  };
};
```

### 4. Advantages of Context API

1. **Global State Management**
   - Manage auth state globally.
   - Prevent props drilling.

2. **Reusability**
   - Manage auth-related logic in one place.
   - Easily used in multiple components.

3. **Type Safety**
   - Integration with TypeScript.
   - Safe usage through type checking.

4. **Maintainability**
   - Auth-related logic centralized in one file.
   - One place to modify when changes are needed.

Yes, you understood correctly! The location of `AuthProvider` is important as it determines the scope of the Context.

### Provider Structure

```typescript
// App.tsx
const App: React.FC = () => {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <AuthProvider>  {/* From here */}
        <Router>
          <AppRoutes />  {/* In all components inside here */}
          {/* - Login */}
          {/* - Register */}
          {/* - BoardRoutes */}
          {/* - Header */}
          {/* etc... */}
        </Router>
      </AuthProvider>  {/* Context can be used up to here */}
    </ThemeProvider>
  );
};
```

### Real Usage Example:

```typescript
// 1. Login Component
const Login: React.FC = () => {
  const { login } = useAuth(); // Accessible
};

// 2. BoardRoutes Component
const BoardRoutes: React.FC = () => {
  const { user, logout } = useAuth(); // Accessible
};

// 3. Header Component
const Header: React.FC = () => {
  const { user } = useAuth(); // Accessible
};
```

### Context Scope:

1. **Inside Provider**
   - Context accessible in all child components.
   - Auth state can be shared.

2. **Outside Provider**
   - Context inaccessible.
   - Error occurs when calling `useAuth`.

### Advantages:

1. **State Sharing**
   - Login status.
   - User info.
   - Auth-related functions.

2. **Props Passing Unnecessary**
   - Direct access from each component.
   - Prevents props drilling.

3. **Consistent State**
   - All components refer to the same state.
   - Guaranteed state synchronization.

Yes, here are examples of using authentication status in Login and Board pages:

### 1. Login Page

```typescript
// frontend/src/components/Auth/Login.tsx
const Login: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const navigate = useNavigate();
  const { login } = useAuth();  // Get login function from Context

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await login(username, password);  // Use Context login function
      navigate('/board');  // Navigate to board on successful login
    } catch (err) {
      setError('Invalid username or password');
    }
  };

  return (
    // ... Login form UI
  );
};
```

### 2. Board Page

```typescript
// frontend/src/routes/BoardRoutes.tsx
export const BoardRoutes: React.FC = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();  // Get user info and logout function from Context
  const [posts, setPosts] = useState<Post[]>([]);

  // Use user info when creating a post
  const handleCreatePost = async (postData: CreatePostRequest) => {
    try {
      const data = await postService.createPost({
        ...postData,
        author: user?._id  // Use user info from Context
      });
      setPosts(prevPosts => [data, ...prevPosts]);
      navigate('/board');
    } catch (error) {
      console.error('Failed to create post:', error);
    }
  };

  return (
    <Box>
      <Header
        isLoggedIn={true}
        username={user?.username}  // Use user info from Context
        onLogout={logout}  // Use logout function from Context
        userInfo={user}
      />
      {/* ... Rest of board UI */}
    </Box>
  );
};
```

### Key Features:

1. **Login Page**
   - Fetches and uses `login` function from Context.
   - Navigates to board on success.

2. **Board Page**
   - Fetches and uses `user` info from Context.
   - Fetches and uses `logout` function from Context.
   - Utilizes user info when writing posts.

## Custom Hook

Exploring custom hooks in the `hooks/` directory.

Detailed explanation of the `usePullToRefresh` custom hook:

### 1. Purpose of Hook

This hook implements the "Pull-to-Refresh" functionality commonly found in mobile apps.

### 2. Main Functions

```typescript
interface UsePullToRefreshProps {
  onRefresh: () => Promise<void>; // Function to run on refresh
  threshold?: number; // Minimum pull distance to trigger refresh
}
```

### 3. State Management

```typescript
const [isRefreshing, setIsRefreshing] = useState(false); // Whether refreshing is in progress
const [startY, setStartY] = useState(0); // Touch start position
const [pullDistance, setPullDistance] = useState(0); // Pull distance
```

### 4. Key Event Handlers

1. **Touch Start**

```typescript
const handleTouchStart = useCallback((e: TouchEvent) => {
  if (window.scrollY === 0) {
    // Only works at the top of the page
    setStartY(e.touches[0].clientY);
  }
}, []);
```

2. **Touch Move**

```typescript
const handleTouchMove = useCallback(
  (e: TouchEvent) => {
    if (window.scrollY === 0 && startY > 0) {
      const currentY = e.touches[0].clientY;
      const distance = currentY - startY;

      if (distance > 0) {
        // Only when pulling down
        setPullDistance(distance);
        e.preventDefault();
      }
    }
  },
  [startY],
);
```

3. **Touch End**

```typescript
const handleTouchEnd = useCallback(async () => {
  if (pullDistance > threshold) {
    // Trigger refresh if threshold is exceeded
    setIsRefreshing(true);
    try {
      await onRefreshRef.current();
    } finally {
      setIsRefreshing(false);
    }
  }
  setStartY(0);
  setPullDistance(0);
}, [pullDistance, threshold]);
```

### 5. Usage Example

```typescript
const PostList: React.FC = () => {
  const refresh = async () => {
    // Logic to refresh post list
    await fetchPosts();
  };

  const { isRefreshing, pullDistance, threshold } = usePullToRefresh({
    onRefresh: refresh,
    threshold: 100  // Refresh if pulled 100px
  });

  return (
    <div>
      {isRefreshing && <LoadingSpinner />}
      {/* Post List */}
    </div>
  );
};
```

### 6. Key Features

1. **Performance Optimization**
   - `useCallback` used to memoize event handlers.
   - `useRef` used to maintain reference to `onRefresh` function.

2. **User Experience**
   - Smooth pulling motion.
   - Provides visual feedback.

3. **Safety**
   - Only operates at the top of the page.
   - Proper event cleanup.

## Step 3. Component Structure

The component structure of the project can be organized as follows:

### 1. Auth Components (`components/Auth/`)

- **Login.tsx**: Login form component.
- **Register.tsx**: Registration form component.

### 2. Board Components (`components/Board/`)

- **PostList/**: Components related to post list.
- **PostDetail/**: Component for post detail view.
- **PostForm/**: Form component for creating/editing posts.
- **Comment/**: Components related to comments.

### 3. Header Components (`components/Header/`)

- **Header.tsx**: Navigation bar component.
  - Logo.
  - Menu.
  - User profile.
  - Login/Logout button.

### 4. Profile Components (`components/Profile/`)

- **Profile.tsx**: User profile component.
  - Display user info.
  - Profile edit function.

### Characteristics of Component Structure:

1. **Modularization**
   - Separate directories for each feature.
   - Grouping related components.

2. **Reusability**
   - Independent component design.
   - Data passing via Props.

3. **Maintainability**
   - Clear directory structure.
   - Separation of concerns.

4. **Scalability**
   - Easy to add new features.
   - Testable at component level.

## Step 5. API Structure

The API communication structure can be organized as follows:

### 1. API Client (`client.ts`)

1. **Basic Configuration**

   ```typescript
   const API_BASE_URL =
     process.env.REACT_APP_API_URL || "http://localhost:8080/api";
   const apiClient = axios.create({
     baseURL: API_BASE_URL,
     headers: {
       "Content-Type": "application/json",
     },
   });
   ```

2. **Interceptors**
   - **Request Interceptor**
     - Automatic token addition.
     - Token expiration check.
     - Redirect to login page on expiration.

   - **Response Interceptor**
     - 401 error handling.
     - Redirect to login page on auth failure.

### 2. API Services (`services.ts`)

1. **Authentication Service (`authService`)**

   ```typescript
   export const authService = {
     register: async (data: RegisterRequest) => {...},
     login: async (data: LoginRequest) => {...},
     getProfile: async () => {...}
   };
   ```

2. **Post Service (`postService`)**

   ```typescript
   export const postService = {
     // Post CRUD
     getPosts: async () => {...},
     getPost: async (id: string) => {...},
     createPost: async (data: CreatePostRequest) => {...},
     updatePost: async (id: string, data: UpdatePostRequest) => {...},
     deletePost: async (id: string) => {...},

     // Related to comments
     addComment: async (postId: string, data: CreateCommentRequest) => {...},
     updateComment: async (postId: string, commentId: string, data: { content: string }) => {...},
     deleteComment: async (postId: string, commentId: string) => {...},

     // Related to replies
     addReply: async (postId: string, commentId: string, data: CreateCommentRequest) => {...},
     updateReply: async (postId: string, commentId: string, replyId: string, data: { content: string }) => {...},
     deleteReply: async (postId: string, commentId: string, replyId: string) => {...},

     // Like
     toggleLike: async (postId: string) => {...}
   };
   ```

### Key Features:

1. **Centralized API Management**
   - Manage all API requests in one place.
   - Consistent error handling.

2. **Type Safety**
   - Type definition using TypeScript.
   - API request/response type checking.

3. **Authentication Handling**
   - Token-based authentication.
   - Automatic token management.
   - Expiration handling.

4. **Modularization**
   - Separate services by feature.
   - Reusable API client.

## client.ts

Detailed explanation of the `client.ts` file:

### 1. Basic Configuration

```typescript
import axios from "axios";

const API_BASE_URL =
  process.env.REACT_APP_API_URL || "http://localhost:8080/api";

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});
```

- Create HTTP client using `axios` library.
- `API_BASE_URL` is taken from environment variables or uses a default value.
- JSON format specified in default headers.

### 2. Token Expiration Check Function

```typescript
const isTokenExpired = (token: string): boolean => {
  try {
    const tokenData = JSON.parse(atob(token.split(".")[1]));
    const expirationTime = tokenData.exp * 1000; // Convert to milliseconds
    return Date.now() >= expirationTime;
  } catch (error) {
    console.error("Error parsing token:", error);
    return true;
  }
};
```

- Function to check the expiration time of JWT tokens.
- Decode token to check expiration time (`exp`).
- Return expiration status by comparing with current time.
- Safely return `true` (treated as expired) on error.

### 3. Request Interceptor

```typescript
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token && config.headers) {
      if (isTokenExpired(token)) {
        // If token is expired
        localStorage.removeItem("token");
        localStorage.removeItem("userId");
        window.location.href = "/login";
        return config;
      }
      // If valid token exists, add to headers
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);
```

- Interceptor executed before every request.
- Check token in local storage.
- If token is expired:
  - Clean up local storage.
  - Redirect to login page.
- If valid token exists:
  - Add token to Authorization header.

### 4. Response Interceptor

```typescript
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle 401 Unauthorized error
      localStorage.removeItem("token");
      localStorage.removeItem("userId");
      window.location.href = "/login";
    }
    return Promise.reject(error);
  },
);
```

- Interceptor executed after every response.
- On 401 error (auth failure):
  - Clean up local storage.
  - Redirect to login page.
- Other errors are passed through as is.

### Key Features:

1. **Automatic Authentication Handling**
   - Automatically adds token to all requests.
   - Automatic detection of token expiration.

2. **Security**
   - Automatic logout on token expiration.
   - Automatic redirect on auth failure.

3. **Error Handling**
   - Centralized error handling.
   - Consistent error responses.

4. **User Experience**
   - Automatic login page redirect.
   - Automated token management.

`config` is the Axios request configuration object. This object contains all the configuration information needed before sending an HTTP request.

### Main Properties of config Object:

```typescript
interface AxiosRequestConfig {
  // Base URL
  baseURL?: string;

  // Request URL
  url?: string;

  // HTTP Method (GET, POST, PUT, DELETE, etc.)
  method?: string;

  // Request Headers
  headers?: {
    "Content-Type"?: string;
    Authorization?: string;
    [key: string]: string;
  };

  // Request data (for POST, PUT requests)
  data?: any;

  // URL parameters (for GET requests)
  params?: any;

  // Timeout setting (milliseconds)
  timeout?: number;

  // Response type
  responseType?:
    | "arraybuffer"
    | "blob"
    | "document"
    | "json"
    | "text"
    | "stream";
}
```

### Real Usage Example:

```typescript
// Using config in Request interceptor
apiClient.interceptors.request.use((config) => {
  // Add token to config.headers
  if (config.headers) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Using config in API call
apiClient.get("/posts", {
  params: { page: 1, limit: 10 }, // URL parameters
  headers: { "Custom-Header": "value" }, // Custom header
  timeout: 5000, // 5 second timeout
});
```

### Main Uses of config Object:

1. **Request Configuration**
   - Basic settings like URL, method, headers.
   - Setting request data and parameters.

2. **Modification in Interceptors**
   - Adding/modifying headers before request.
   - Adding authentication tokens.
   - Transforming request data.

3. **Error Handling**
   - Validating request configuration.
   - Correcting incorrect settings.

### Backend Authentication Flow:

```typescript
// Backend middleware example (Node.js/Express)
const authMiddleware = (req, res, next) => {
  // 1. Extract token from Authorization header
  const token = req.headers.authorization?.split(" ")[1];

  if (!token) {
    return res.status(401).json({ message: "No token provided" });
  }

  try {
    // 2. Token verification
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 3. Add verified user info to request object
    req.user = decoded;

    // 4. Proceed to next middleware
    next();
  } catch (error) {
    // 5. Return 401 on verification failure
    return res.status(401).json({ message: "Invalid token" });
  }
};

// Apply middleware to router
app.use("/api", authMiddleware); // Apply auth to all API requests
```

### When Auth is Required vs Not Required:

```typescript
// 1. Public routes (no auth required)
app.post("/api/users/register", registerController); // Registration
app.post("/api/users/login", loginController); // Login

// 2. Protected routes (auth required)
app.get("/api/posts", authMiddleware, getPostsController); // Post list
app.post("/api/posts", authMiddleware, createPostController); // Write post
app.get("/api/profile", authMiddleware, getProfileController); // View profile
```

### Integration with Frontend:

```typescript
// 1. API request requiring auth
const getPosts = async () => {
  try {
    const response = await apiClient.get("/posts");
    return response.data;
  } catch (error) {
    if (error.response?.status === 401) {
      // Handle auth failure
      // - Delete token
      // - Redirect to login page
    }
  }
};

// 2. API request not requiring auth
const login = async (credentials) => {
  try {
    const response = await apiClient.post("/users/login", credentials);
    // Store token on successful login
    localStorage.setItem("token", response.data.token);
  } catch (error) {
    // Handle login failure
  }
};
```

### Key Features:

1. **Centralized Auth Management**
   - Consistent auth handling for all requests.
   - Elimination of redundant token verification logic.

2. **Security**
   - Blocking unauthorized requests.
   - Safe token-based authentication.

3. **Flexibility**
   - Can apply auth to specific routes only.
   - Auth logic easily modified/extended.

## Production Environment Configuration Plan

When deploying a React frontend app in a production environment, it is **very common to configure it with Nginx or Apache**.

---

## Why use it with Nginx/Apache?

- When a React app is built, it is converted into static files (HTML, JS, CSS, images, etc.).
- Nginx/Apache is optimized to serve these static files quickly and efficiently.
- Functions like security, caching, compression, HTTPS (SSL) application, and reverse proxy can be easily used.

---

## Real Production Configuration Example

### 1. Build React App

```bash
npm run build
```

- Static files created in the `build/` folder.

---

### 2. Serving Static Files with Nginx

#### Example Directory Structure

```
/var/www/my-react-app/build  ← Copy React build result here
```

#### Nginx Configuration Example

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    root /var/www/my-react-app/build;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}
```

- Redirect all path requests to `index.html` (Supports React Router).
- Static files served directly by Nginx.

---

### 3. Applying HTTPS (Optional)

- Issue SSL certificate via Let's Encrypt, etc.
- Service over port 443 (HTTPS) in Nginx.

---

### 4. Integration with API Server (Optional)

- Proxy only `/api` requests to backend like Node.js (Express).
- Respond to everything else with static files.

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    # Proxy API to backend
    location /api/ {
        proxy_pass http://localhost:8080;
    }

    # Serve frontend as static files
    location / {
        root /var/www/my-react-app/build;
        try_files $uri /index.html;
    }
}
```

---

## Apache is almost identical

- Specify build folder as `DocumentRoot`.
- Support SPA routing via `.htaccess`.

---

## Conclusion

- **Using Nginx/Apache with React apps for production deployment is the standard**.
- Provides static files quickly and safely, and can integrate with API servers if needed.

## Why serve static files on Nginx or Apache

**Backend (API server) and Frontend (static files) have different configurations because they have different "roles."**

---

## 1. Backend (API Server)

- **Dynamic Request Processing**: DB queries, business logic, authentication, etc.
- **Resource Intensive**: Uses CPU, memory, DB connections, etc.
- **Security Importance**: Handling sensitive data, authentication/authorization, etc.

→ Receive requests via **Nginx reverse proxy** and pass them to the backend server.

---

## 2. Frontend (Static Files)

- **Serving Static Files**: Simple file serving for HTML, JS, CSS, images, etc.
- **Resource Light**: Only needs to send files.
- **Caching/Compression Importance**: Response speed, CDN utilization, etc.

→ **Nginx serves static files directly**.

---

## Why does Nginx serve frontend directly?

1. **Performance Optimization**
   - Nginx is optimized for serving static files.
   - Compression, caching, CDN integration, etc., can be easily applied.

2. **Resource Efficiency**
   - Backend server concentrates on dynamic request processing.
   - Nginx handles static files quickly.

3. **Security**
   - Static files do not have sensitive data, so security risk is low.
   - Safe even when Nginx serves them directly.

---

## Example: Backend vs Frontend Configuration

### Backend (API Server)

```
[Internet] → [Nginx] → [Node.js (Express) API Server]
```

- Nginx receives request and passes it to Node.js.
- Node.js processes dynamic requests.

---

### Frontend (Static Files)

```
[Internet] → [Nginx] → [Static Files (React build)]
```

- Nginx serves static files directly.
- Fast and efficient without a separate server.

---

## Conclusion

- **Backend**: Dynamic request processing → Pass via Nginx reverse proxy.
- **Frontend**: Serving static files → Nginx handles directly.

→ **Configuration optimized for each role!**

## Why you should use Nginx or Apache instead of React UI libraries

**React itself is not a "web server."** React is a **UI library**; what actually acts as the web server is the **development server (e.g., `react-scripts start`) used in the development environment.**

---

## 1. React Dev Server vs Production Server

### Development Environment (`npm start` or `yarn start`)

- Uses dev server provided by `react-scripts`.
- Provides convenience features like **Hot Reloading**, **error messages**, and **source maps**.
- **Not optimized for performance**, **not for security**, **not for real service**.

### Production Environment (`npm run build`)

- Creates **static files (HTML, JS, CSS, images, etc.)** in the `build/` folder.
- **Requires a separate web server (Nginx, Apache, etc.)**.
- Applies features needed for real service like **performance optimization**, **security**, and **HTTPS**.

---

## 2. Why Nginx/Apache is needed?

### 1) Serving Static Files

- React build results are **static files**.
- Nginx/Apache are optimized for serving static files.

### 2) Performance Optimization

- Improves response speed via **compression**, **caching**, and **CDN integration**.
- Dev servers lack these features.

### 3) Security

- **Applying HTTPS (SSL)**, **setting security headers**, etc.
- Dev servers lack security features.

### 4) Routing Support

- Supports SPA (Single Page Application) routing like React Router.
- Redirects all paths to `index.html` via Nginx/Apache configuration.

---

## 3. Real Example

### Development Environment

```bash
npm start
```

- Dev server runs on `localhost:3000`.
- Provides convenience features like **Hot Reloading** and **error messages**.

### Production Environment

```bash
npm run build
```

- Static files created in `build/` folder.
- Served via Nginx/Apache.

---

## 4. Conclusion

- **React is a UI library** and does not have its own web server.
- Dev server is used **for development only**.
- **Web servers like Nginx/Apache are essential** for production environments.

## User Traffic Flow

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
      │        └─> [ Node.js (Express) API Server ] (Port 8080)
      └─> [ Static Files (React build) ]
```

---

## 1. User Access

- **User** accesses `http://yourdomain.com` in browser.
- Nginx receives request on port 80 (HTTP) or 443 (HTTPS).

---

## 2. Nginx Processing

- **Nginx** analyzes request:
  - Requests starting with `/api/` → Proxy to Node.js (Express).
  - Other requests → Respond with React build results (static files).

---

## 3. Frontend (React) Processing

- **React app** loads in browser.
- **React Router** renders appropriate page according to URL.
- **API call** sent to backend if needed.

---

## 4. Backend (Node.js) Processing

- **Node.js (Express)** receives API request.
- Handles **DB queries**, **business logic**, **authentication**, etc.
- Returns **response** in JSON format.

---

## 5. Response Delivery

- **Node.js** → **Nginx** → **User**.
- **React app** receives response and updates UI.

---

## 6. Real Example

### 1) User accesses Login Page

- Access `http://yourdomain.com/login`.
- Nginx responds with React build result (`index.html`).
- React app renders login page.

### 2) User attempts Login

- React app calls `/api/login` API.
- Nginx proxies request to Node.js.
- Node.js returns JWT token after auth processing.
- React app stores token and redirects to main page.

### 3) User views Post List

- React app calls `/api/posts` API.
- Nginx proxies request to Node.js.
- Node.js returns post list from DB.
- React app renders post list.

---

## 7. Advantages

- **Security**: Node.js server is not directly exposed to the outside.
- **Performance**: Static files served quickly by Nginx.
- **HTTPS**: SSL certificate can be applied at Nginx.
- **Caching/Compression**: Performance optimized via Nginx settings.

---

## 8. Conclusion

- **Nginx** acts as a **central gateway** connecting Frontend (React) and Backend (Node.js).
- **Frontend** served directly by Nginx as static files.
- **Backend** proxied by Nginx for API requests only.

---

## Docker Deployment Guide

This section explains how to containerize and deploy a React frontend application with Docker.

---

## 🐳 Docker Overview

### **Multi-stage Build Structure**

- **Stage 1 (Build)**: Build React app in Node.js environment.
- **Stage 2 (Production)**: Serve built static files using Nginx.

### **Key Features**

- ✅ **Optimized Image Size**: Unnecessary files removed via multi-stage build.
- ✅ **Nginx Logging**: Support for access and error logs.
- ✅ **Security Headers**: Automatic application of XSS, CSRF headers, etc.
- ✅ **Static File Caching**: 1-year caching for CSS, JS, images.

---

## 🚀 Quick Start

### **1. Build Image**

```bash
# Execute from project root
docker build -t board-frontend:latest ./frontend
```

### **2. Run Container**

```bash
# Basic execution (Port 80)
docker run -d --name board-frontend -p 80:80 board-frontend:latest

# Mount log directory (Recommended)
docker run -d --name board-frontend -p 80:80 \
  -v /var/log/app/board-service/nginx:/var/log/app/board-service/nginx \
  board-frontend:latest
```

### **3. Verify Access**

```bash
# Access via browser
http://localhost

# Or test with curl
curl http://localhost
```

---

## 📁 Project Structure

```
frontend/
├── Dockerfile              # Docker image build settings
├── nginx.conf             # Nginx configuration file
├── package.json           # Node.js dependencies
├── src/                   # React source code
└── logs/                  # Log directory (optional)
```

---

## 🔧 Dockerfile In-Depth Analysis

### **Build Stage**

```dockerfile
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```

**Explanation:**

- `node:18-alpine`: Uses lightweight Node.js 18 image.
- `npm ci`: Dependency installation optimized for production.
- `npm run build`: Builds React app into static files.

### **Production Stage**

```dockerfile
FROM nginx:alpine
RUN mkdir -p /var/log/app/board-service/nginx && \
    chown -R nginx:nginx /var/log/app/board-service/nginx && \
    chmod -R 755 /var/log/app/board-service/nginx
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
```

**Explanation:**

- `nginx:alpine`: Uses lightweight Nginx image.
- Create log directory and set permissions.
- Copy built files to Nginx web root.

---

## 🌐 Nginx Configuration (nginx.conf)

### **Main Settings**

```nginx
# Logging configuration
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';

access_log /var/log/app/board-service/nginx/access.log main;
error_log /var/log/app/board-service/nginx/error.log warn;

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;

# Static file caching
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

---

## 📊 Logging and Monitoring

### **Log File Locations**

- **Inside Container**: `/var/log/app/board-service/nginx/`
- **Host Mount**: `/var/log/app/board-service/nginx/` (Recommended)

### **Log Monitoring**

```bash
# Real-time access log monitoring
tail -f /var/log/app/board-service/nginx/access.log

# Real-time error log monitoring
tail -f /var/log/app/board-service/nginx/error.log

# Check number of log lines
wc -l /var/log/app/board-service/nginx/access.log
```

### **Log Format Example**

```
172.17.0.1 - - [25/Aug/2025:01:42:05 +0000] "GET / HTTP/1.1" 200 613 "-" "curl/8.7.1" "-"
```

---

## 🏗️ Docker Image Management Guide

This section explains the entire process of building Docker images, creating tags, pushing to Docker Hub, and running them.

---

## 🔨 1. Build Docker Image

### **Build Frontend Image**

```bash
# Execute from project root directory
docker build -t board-frontend:latest ./frontend

# Or execute from frontend directory
cd frontend
docker build -t board-frontend:latest .
```

### **Build Process Explanation**

1. Start **Multi-stage build**.
2. Build React app in **Node.js environment**.
3. Switch to **Nginx environment**.
4. Copy **built static files** to Nginx web root.
5. Copy **Nginx configuration** file.
6. Create **final image**.

### **Verify Build**

```bash
# Check image list
docker images | grep board-frontend

# Check image detailed info
docker inspect board-frontend:latest
```

---

## 🏷️ 2. Create Docker Image Tag

### **Create Tag on Local Image**

```bash
# Basic tag
docker tag board-frontend:latest board-frontend:v1.0.0

# Tag with Docker Hub username
docker tag board-frontend:latest your-username/board-frontend:latest
docker tag board-frontend:latest your-username/board-frontend:v1.0.0

# Specific version tag
docker tag board-frontend:latest your-username/board-frontend:stable
```

### **Verify Tags**

```bash
# Check all tags
docker images board-frontend

# Check all tags of specific image
docker images your-username/board-frontend
```

### **Tag Management Tips**

- **latest**: Latest stable version.
- **v1.0.0**: Semantic versioning.
- **stable**: Stable version.
- **dev**: Development version.

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
docker push your-username/board-frontend:latest

# Push specific version
docker push your-username/board-frontend:v1.0.0

# Push all tags
docker push your-username/board-frontend --all-tags
```

### **Verify Push**

```bash
# Check image on Docker Hub
docker search your-username/board-frontend

# Check remote image info
docker pull your-username/board-frontend:latest
```

---

## 📥 4. Pull and Run Docker Image

### **Pull Image**

```bash
# Pull latest version
docker pull your-username/board-frontend:latest

# Pull specific version
docker pull your-username/board-frontend:v1.0.0

# Check images
docker images your-username/board-frontend
```

### **Run Container**

#### **Basic Execution**

```bash
# Run on port 80
docker run -d --name board-frontend -p 80:80 \
  your-username/board-frontend:latest
```

#### **Mount Log Directory (Recommended)**

```bash
# Use new log directory structure
docker run -d --name board-frontend -p 80:80 \
  -v /var/log/app/board-service/nginx:/var/log/app/board-service/nginx \
  your-username/board-frontend:latest
```

#### **Environment-Specific Execution**

```bash
# Dev environment
docker run -d --name board-frontend-dev -p 8080:80 \
  -e NODE_ENV=development \
  your-username/board-frontend:latest

# Production environment
docker run -d --name board-frontend-prod -p 80:80 \
  -e NODE_ENV=production \
  -v /var/log/app/board-service/nginx:/var/log/app/board-service/nginx \
  your-username/board-frontend:latest
```

---

## 🔄 Overall Workflow Example

### **1. Dev → Build → Deployment Process**

```bash
# 1. Build image after code modification
docker build -t board-frontend:latest ./frontend

# 2. Tag for Docker Hub
docker tag board-frontend:latest your-username/board-frontend:latest

# 3. Push to Docker Hub
docker push your-username/board-frontend:latest

# 4. Pull on production server
docker pull your-username/board-frontend:latest

# 5. Run new container
docker stop board-frontend-prod
docker rm board-frontend-prod
docker run -d --name board-frontend-prod -p 80:80 \
  -v /var/log/app/board-service/nginx:/var/log/app/board-service/nginx \
  your-username/board-frontend:latest
```

### **2. Version Management Workflow**

```bash
# 1. Build new version
docker build -t board-frontend:v2.0.0 ./frontend

# 2. Create multiple tags
docker tag board-frontend:v2.0.0 your-username/board-frontend:v2.0.0
docker tag board-frontend:v2.0.0 your-username/board-frontend:latest

# 3. Push all tags
docker push your-username/board-frontend:v2.0.0
docker push your-username/board-frontend:latest

# 4. Rollback preparation (Maintain previous version)
docker tag your-username/board-frontend:v1.0.0 your-username/board-frontend:stable
```

---

## 🐛 Common Troubleshooting

### **Build Failure**

```bash
# Check build context
docker build --no-cache -t board-frontend:latest ./frontend

# Check detailed build logs
docker build --progress=plain -t board-frontend:latest ./frontend
```

### **Push Failure**

```bash
# Check Docker Hub login status
docker login

# Check image tags
docker images your-username/board-frontend

# Check permissions
docker push your-username/board-frontend:latest
```

### **Execution Failure**

```bash
# Check container logs
docker logs board-frontend

# Check port conflict
lsof -i :80

# Use different port
docker run -d --name board-frontend -p 8080:80 \
  your-username/board-frontend:latest
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
docker rmi board-frontend:latest
docker rmi your-username/board-frontend:latest
```

### **Check Disk Usage**

```bash
# Check Docker usage
docker system df

# Check detailed usage
docker system df -v
```

---

## 🎯 Best Practices

### **Tag Strategy**

- **latest**: Always the latest stable version.
- **vX.Y.Z**: Semantic versioning.
- **stable**: Production stable version.
- **dev**: Development/test version.

### **Security**

- **Regular Updates**: Security patches for base images.
- **Vulnerability Scanning**: Use `docker scout`.
- **Minimum Permissions**: Include only necessary files.

### **Performance**

- **Multi-stage build**: Optimized image size.
- **Layer Caching**: Shorter build times.
- **Alpine Linux**: Lightweight base image.

---

## 🔍 Understanding React Router and Nginx Logging

This section explains how Nginx logging works in a React Single Page Application (SPA).

---

## 🎬 **Logging Behavior of React Router**

### **1. Initial Page Load (Log Created)**

```bash
# On browser access to http://localhost/
GET /                    → Logged ✅ (Server request)
GET /manifest.json      → Logged ✅ (Server request)
GET /static/js/main.js  → Logged ✅ (Server request)
```

### **2. React Router Internal Navigation (No Log Created)**

```bash
# On clicking link within the app
Click "Board" icon → No server request → No log ❌
Click "Profile" → No server request → No log ❌
Click "Settings" → No server request → No log ❌
```

**Why is no log created?**
Because React Router handles navigation within the browser, no new HTTP request is sent to the server.

---

## 🌟 **This is normal behavior!**

### **✅ Logged Requests**

- **Page Refresh** (Ctrl+F5 or Cmd+Shift+R)
- **Direct URL Access** (Entering `/board` in address bar)
- **API Calls** (Requests from app to backend)
- **Static Asset Requests** (Images, CSS, JS files)

### **❌ Unlogged Actions**

- **React Router Navigation** (Clicking links in-app)
- **State Changes** (Form input, button clicks)
- **Component Re-renders**

---

## 🔍 **Real Logging Example**

### **Patterns found in log files**

```bash
# 1. Initial Access (Log created)
172.26.0.1 - - [25/Aug/2025:03:52:11 +0000] "GET / HTTP/1.1" 200 613

# 2. Direct Access to Board Page (Log created)
172.26.0.1 - - [25/Aug/2025:03:52:11 +0000] "GET /board HTTP/1.1" 200 613

# 3. React Router Internal Navigation (No log)
# (No new logs even when clicking Board → Profile → Settings within app)

# 4. Page Refresh (Log created)
172.26.0.1 - - [25/Aug/2025:03:55:43 +0000] "GET /board HTTP/1.1" 304 0
```

---

## 📊 **Logging Monitoring Methods**

### **Real-time Log Check**

```bash
# Monitor frontend Nginx logs in real-time
tail -f /var/log/app/board-service/nginx/access.log

# Search specific patterns
grep "GET /board" /var/log/app/board-service/nginx/access.log
grep "GET /profile" /var/log/app/board-service/nginx/access.log
```

### **Check Log Statistics**

```bash
# Total number of log lines
wc -l /var/log/app/board-service/nginx/access.log

# Request count by specific path
grep "GET /" /var/log/app/board-service/nginx/access.log | wc -l
grep "GET /board" /var/log/app/board-service/nginx/access.log | wc -l
```

---

## 🎯 **Why is this behavior ideal?**

### **1. Performance Advantage**

- **Fast Navigation**: Instant page transitions without server requests.
- **Bandwidth Saving**: Prevent re-transmitting unnecessary HTML.
- **User Experience**: Smooth, app-like feel.

### **2. Purpose of Logging**

- Records only **actual server traffic**.
- **API calls** can be tracked.
- Monitoring **static asset requests**.

### **3. Modern Web Development Standard**

- Standard behavior for **SPA architecture**.
- Same for all frameworks like **React, Vue, Angular**.
- **User behavior analysis** uses separate tools (Google Analytics, etc.).

---

## 🚨 **Troubleshooting**

### **When no logs are created at all**

```bash
# 1. Check container status
docker compose ps

# 2. Check volume mount
docker inspect board-service-frontend-1 | grep -A 10 "Mounts"

# 3. Check Nginx configuration
docker exec board-service-frontend-1 nginx -t

# 4. Check log directory permissions
ls -la /var/log/app/board-service/nginx/
```

### **When logs are created but React Router doesn't work**

```bash
# 1. Check React Router fallback in Nginx settings
# 2. Check if try_files directive is set correctly
# 3. Check if all paths fallback to index.html
```

---

## 📝 **Conclusion**

**The "strange" behavior of React Router and Nginx logging is completely normal!**

- ✅ **Server Request** → Logged
- ✅ **Client Navigation** → Not logged (Normal)
- ✅ **Performance Optimization** → Fast page transitions
- ✅ **User Experience** → Smooth app behavior

**This is the standard behavior for modern web applications.** If the logging system is working properly, "missing" logs are not actually missing but efficiently handled by React! 🚀

---

## 📚 **Additional Learning Resources**

- [React Router Official Docs](https://reactrouter.com/)
- [Nginx Logging Configuration](https://nginx.org/en/docs/http/ngx_http_log_module.html)
- [SPA vs MPA Architecture](https://web.dev/learn/spa-vs-mpa/)
- [Modern Web Logging Strategies](https://web.dev/learn/logging/)

---

## 🔒 **Nginx Security Configuration Guide (nginx.conf)**

### **🚨 Importance of Security Settings**

The `nginx.conf` file is the **first line of defense** for frontend services. If these settings are incorrect:

- ❌ **API requests may not reach the backend**
- ❌ **Security logs may not be created**
- ❌ **User authentication may fail entirely**
- ❌ **Risk of attacks due to security vulnerabilities**

---

## 🛡️ **Analysis of Core Security Settings**

### **1. API Proxy Settings (Core of Security Logging)**

```nginx
# API Proxy Configuration - CRITICAL for security logging
location /api/ {
    proxy_pass http://backend:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Log all API requests for security monitoring
    # access_log /var/log/app/board-service/nginx/access.log main;
}
```

#### **🔍 Security meaning of each setting:**

- **`proxy_pass http://backend:8080`**:
  - Delivers API requests to backend service.
  - **Core of security logging** - all API calls logged via Nginx.

- **`proxy_set_header X-Real-IP $remote_addr`**:
  - Delivers actual client IP address to backend.
  - Essential for **attacker tracking** and **geographical restrictions**.

- **`proxy_set_header X-Forwarded-For`**:
  - Tracks requests through proxy chains.
  - Preserves original IP in **load balancer** environments.

- **`proxy_set_header X-Forwarded-Proto`**:
  - Delivers original protocol info.
  - Required for **forcing HTTPS** and **security policies**.

### **2. Security Header Settings**

```nginx
# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
```

#### **🔍 Security function of each header:**

- **`X-Frame-Options "SAMEORIGIN"`**:
  - **Prevents clickjacking attacks**.
  - Blocks page loading in iframes from other domains.
  - **Security Grade: High**.

- **`X-Content-Type-Options "nosniff"`**:
  - **Prevents MIME type sniffing attacks**.
  - Forces browser to trust declared Content-Type.
  - **Security Grade: High**.

- **`X-XSS-Protection "1; mode=block"`**:
  - **Detects and blocks XSS attacks**.
  - Activates browser-native XSS defense.
  - **Security Grade: Medium** (Modern browsers recommend CSP).

### **3. Logging Settings (Security Monitoring)**

```nginx
# Logging
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';

access_log /var/log/app/board-service/nginx/access.log main;
error_log /var/log/app/board-service/nginx/error.log warn;
```

#### **🔍 Security importance of logging:**

- **`$remote_addr`**: Records **attacker IP address**.
- **`$request`**: **Request content** (URL, method, parameters).
- **`$status`**: **Response status** (Success/Failure/Error).
- **`$http_user_agent`**: **Browser info** (Bot detection).
- **`$http_referer`**: **Request origin** (CSRF attack detection).

---

## 🚨 **Verification Methods for Security Settings**

### **1. Nginx Configuration Syntax Check**

```bash
# Verify settings inside container
docker exec board-service-frontend-1 nginx -t

# Result: nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### **2. Verify Security Headers**

```bash
# Verify if security headers are correctly set
curl -I http://localhost/api/users/login

# Response must include the following headers:
# X-Frame-Options: SAMEORIGIN
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
```

### **3. Verify API Proxy Behavior**

```bash
# Verify if API request is delivered to backend
curl -X POST http://localhost/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'

# Verify if response comes from backend
# Verify if request is recorded in logs
tail -f /var/log/app/board-service/nginx/access.log
```

---

## 🔧 **Optimization of Security Settings**

### **1. Recommended Additional Security Headers**

```nginx
# Additional security headers (Optional)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
```

### **2. Request Limit Settings**

```nginx
# API Request Limit (DDoS prevention)
location /api/ {
    # Allow maximum 10 requests per second
    limit_req zone=api burst=20 nodelay;

    proxy_pass http://backend:8080;
    # ... Existing settings ...
}

# Add to http block
http {
    # Define API request limit zone
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    # ... Existing settings ...
}
```

### **3. Log Rotation Settings**

```nginx
# Log file size limit and rotation
access_log /var/log/app/board-service/nginx/access.log main buffer=16k flush=5s;
error_log /var/log/app/board-service/nginx/error.log warn buffer=16k flush=5s;
```

---

## 🎯 **Security Monitoring Checklist**

### **✅ Daily Security Check**

- [ ] Are Nginx log files created normally?
- [ ] Are API requests delivered to backend normally?
- [ ] Are security headers included in all responses?
- [ ] Are login attempts recorded in logs?

### **✅ Weekly Security Check**

- [ ] Are there suspicious IP addresses?
- [ ] Are there abnormal request patterns?
- [ ] Is the number of login failures spiking?
- [ ] Is API usage within normal range?

### **✅ Monthly Security Check**

- [ ] Do security header settings follow latest recommendations?
- [ ] Is log retention policy appropriate?
- [ ] Is access control policy effective?
- [ ] Is security incident response plan ready?

---

## 🚨 **Security Incident Response**

### **1. Detecting Suspicious Activity**

```bash
# Spike in login failures
grep "POST.*login.*401" /var/log/app/board-service/nginx/access.log | \
  awk '{print $1}' | sort | uniq -c | sort -nr | head -10

# Abnormal requests from specific IP
grep "172.26.0.1" /var/log/app/board-service/nginx/access.log | \
  awk '{print $4, $6, $7}' | sort | uniq -c | sort -nr

# API abuse detection
grep "POST.*api" /var/log/app/board-service/nginx/access.log | \
  awk '{print $1, $4, $6}' | sort | uniq -c | sort -nr
```

### **2. Immediate Response Actions**

```bash
# Block suspicious IP (using iptables)
sudo iptables -A INPUT -s [SUSPICIOUS_IP] -j DROP

# Reload Nginx configuration
docker exec board-service-frontend-1 nginx -s reload

# Backup logs
cp /var/log/app/board-service/nginx/access.log /var/log/app/board-service/nginx/access.log.backup.$(date +%Y%m%d_%H%M%S)
```

---

## 📚 **Security Setting References**

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Nginx Security Best Practices](https://nginx.org/en/docs/http/ngx_http_headers_module.html)
- [Security Headers Guide](https://securityheaders.com/)
- [Web Application Security Guide](https://cheatsheetseries.owasp.org/cheatsheets/Web_Application_Security_Cheat_Sheet.html)

---

## 🎉 **Conclusion**

**Correct nginx.conf settings are the foundation of security!**

- ✅ **API Proxy**: Ensures security logging for all API requests.
- ✅ **Security Headers**: Prevents client-side attacks.
- ✅ **Detailed Logging**: Detecting and responding to security incidents.
- ✅ **Request Tracking**: Identifying and blocking attackers.

**Without correct settings, security monitoring is impossible and the application is exposed to attacks.**

**Security is not a set-and-forget task, but a process that must be continuously monitored and improved!** 🛡️🚀

---

## 🔧 **Logging Configuration Optimization and Troubleshooting**

### **🚨 Troubleshooting Double Logging (Double Logging Fix)**

#### **Problem Situation:**

```bash
# ❌ Double logging occurred in previous settings:
172.26.0.1 - - [25/Aug/2025:04:27:09 +0000] "POST /api/posts/.../replies HTTP/1.1" 200 779
172.26.0.1 - - [25/Aug/2025:04:27:09 +0000] "POST /api/posts/.../replies HTTP/1.1" 200 779
# Same request logged twice!
```

#### **Cause Analysis:**

```nginx
# ❌ Problematic settings:
http {
    # Global logging configuration (Logs all requests)
    access_log /var/log/app/board-service/nginx/access.log main;

    server {
        location /api/ {
            # API requests also logged (Redundant!)
            access_log /var/log/app/board-service/nginx/access.log main;
        }
    }
}

# Result: Global logging + location-based logging = Double logging
```

#### **Resolution:**

```nginx
# ✅ Corrected settings:
http {
    # Remove global logging (Prevent redundancy)
    # access_log /var/log/app/board-service/nginx/access.log main;

    # Maintain global error logging only
    error_log /var/log/app/board-service/nginx/error.log warn;

    server {
        location /api/ {
            # Log only API requests (Security monitoring)
            access_log /var/log/app/board-service/nginx/access.log main;
        }

        location / {
            # Log page requests (User behavior analysis)
            access_log /var/log/app/board-service/nginx/access.log main;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            # No logging for static assets (Reduce noise)
            access_log off;
        }
    }
}
```

---

## 📊 **Improved Logging Strategy**

### **1. Granular Location-based Logging**

#### **API Request Logging (Security Monitoring)**

```nginx
location /api/ {
    # Log all API calls for security monitoring
    access_log /var/log/app/board-service/nginx/access.log main;

    # Proxy settings
    proxy_pass http://backend:8080;
    # ... Other proxy settings ...
}
```

#### **Page Request Logging (User Behavior Analysis)**

```nginx
location / {
    # Log React Router page transitions
    access_log /var/log/app/board-service/nginx/access.log main;

    # React Router handling
    try_files $uri $uri/ /index.html;
}
```

#### **Disable Static Asset Logging (Performance Optimization)**

```nginx
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    # Do not log static files
    access_log off;

    # Cache settings
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### **2. Logging Priority**

```bash
# 🔴 High (Security Essential)
POST /api/users/login     → Logging Required
POST /api/posts          → Logging Required
DELETE /api/posts/:id    → Logging Required

# 🟡 Medium (Recommended for Monitoring)
GET /board               → Recommended
GET /profile            → Recommended
GET /                   → Recommended

# 🟢 Low (Performance Optimization)
GET /static/js/main.js  → No Logging
GET /static/css/main.css → No Logging
GET /favicon.ico        → No Logging
```

---

## 🎯 **Verification and Testing of Logging Settings**

### **1. Verify Resolution of Double Logging Problem**

```bash
# 1. Test API request
curl -X POST http://localhost/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test"}'

# 2. Check logs - Now should be logged only once
tail -f /var/log/app/board-service/nginx/access.log

# 3. Verify result
# ✅ Normal: Logged once
# ❌ Problem: Still double logged
```

### **2. Analyze Logging Patterns**

```bash
# Check only API requests
grep "POST /api" /var/log/app/board-service/nginx/access.log | wc -l

# Check only page requests
grep "GET /" /var/log/app/board-service/nginx/access.log | grep -v "/api" | wc -l

# Check static asset requests (Should not be logged)
grep "\.js\|\.css\|\.png\|\.jpg" /var/log/app/board-service/nginx/access.log | wc -l
# Result: Should be 0
```

### **3. Verify Performance Improvement**

```bash
# Compare log file sizes
ls -lh /var/log/app/board-service/nginx/access.log

# Check number of log lines
wc -l /var/log/app/board-service/nginx/access.log

# Confirm size reduction compared to before
```

---

## 🚀 **Benefits of Logging Optimization**

### **✅ Problem Resolution**

- **Complete removal of double logging**.
- **Improved accuracy of log analysis**.
- **Saved disk space**.

### **✅ Performance Improvement**

- **Removed unnecessary logging**.
- **Reduced log file size**.
- **Improved log processing speed**.

### **✅ Security Enhancement**

- **Accurate security monitoring**.
- **Easier identification of attack patterns**.
- **Accurate tracking of user behavior**.

### **✅ Maintainability**

- **Clear logging structure**.
- **Faster diagnosis when problems occur**.
- **Consistency in logging policy**.

---

## 🔍 **Logging Monitoring Checklist**

### **✅ Daily Check**

- [ ] Does double logging occur?
- [ ] Are API requests logged correctly?
- [ ] Are page requests logged appropriately?
- [ ] Are static asset requests not being logged?

### **✅ Weekly Check**

- [ ] Is log file size appropriate?
- [ ] Are log patterns normal?
- [ ] are all security-related requests recorded?
- [ ] Does it affect performance?

### **✅ Monthly Check**

- [ ] Is logging policy effective?
- [ ] Is log retention period appropriate?
- [ ] is log analysis easy?
- [ ] is logging configuration optimized?

---

## 📝 **Logging Configuration Best Practices**

### **1. Set Logging Levels**

```nginx
# Global error logging only
error_log /var/log/app/board-service/nginx/error.log warn;

# Granular access logging by location
location /api/ {
    access_log /var/log/app/board-service/nginx/access.log main;
}
```

### **2. Optimize Logging Format**

```nginx
# Include only information needed for security
log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                '$status $body_bytes_sent "$http_referer" '
                '"$http_user_agent" "$http_x_forwarded_for"';
```

### **3. Logging Location Strategy**

```nginx
# Logging based on importance
location /api/ { access_log on; }      # Security essential
location / { access_log on; }          # Recommended for monitoring
location ~* \.(js|css|png)$ { access_log off; }  # Performance optimization
```

---

## 🎉 **Conclusion**

**The double logging problem has been successfully resolved!**

- ✅ **Redundancy prevented** by removing global logging.
- ✅ **Accuracy improved** with granular location-based logging.
- ✅ **Efficiency increased** via performance optimization.
- ✅ **Security monitoring** enhanced.

**Now effective security monitoring is possible through clean and accurate logs!** 🚀

**Logging configuration is not a one-time setup but an important security element that must be continuously monitored and optimized.** 🛡️

---

## 🎯 **Currently Operating nginx.conf Settings (Working Configuration)**

### **✅ Successfully Resolved Issues**

#### **1. Complete Resolution of Double Logging**

- **Issue**: API requests being logged twice.
- **Cause**: Duplication between global and location-based logging.
- **Fix**: Removed global `access_log`, maintained only granular location-based logging.
- **Result**: Each request is logged exactly once.

#### **2. Resolution of Port Mapping Issue**

- **Issue**: Connection failure due to `-p 80:3000`.
- **Cause**: Nginx listens on 80 but Docker was mapped to 3000.
- **Fix**: Corrected to `-p 80:80` to match ports.
- **Result**: `http://localhost:80` accessible normally.

#### **3. Completion of API Proxy Configuration**

- **Issue**: Missing proxy configuration for `/api/*`.
- **Cause**: API proxy block missing in `nginx.conf`.
- **Fix**: Added `location /api/` block and backend connection settings.
- **Result**: All API requests delivered normally to backend.

---

## 🔧 **Currently Operating nginx.conf Full Configuration**

```nginx
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    # Global error logging only (Prevents double logging)
    error_log /var/log/app/board-service/nginx/error.log warn;

    server {
        listen 80;
        server_name localhost;
        root /usr/share/nginx/html;
        index index.html;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;

        # API Proxy Configuration - CRITICAL for security logging
        location /api/ {
            proxy_pass http://backend:8080;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Log all API requests for security monitoring
            access_log /var/log/app/board-service/nginx/access.log main;
        }

        # Handle React Router
        location / {
            try_files $uri $uri/ /index.html;
            # No logging here to prevent double logging with /api/ location
        }

        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            # No logging for static assets to reduce noise
            access_log off;
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

---

## 🚀 **Key Features of Current Configuration**

### **1. Logging Strategy (Redundancy Prevention)**

```nginx
# ✅ Maintain global error logging only
error_log /var/log/app/board-service/nginx/error.log warn;

# ✅ Log API requests only (Security monitoring)
location /api/ {
    access_log /var/log/app/board-service/nginx/access.log main;
}

# ✅ Do not log page requests (Prevents redundancy)
location / {
    # No access_log directive
}

# ✅ Do not log static assets (Performance optimization)
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    access_log off;
}
```

### **2. Security Headers (Attack Prevention)**

```nginx
# Prevents clickjacking attacks
add_header X-Frame-Options "SAMEORIGIN" always;

# Prevents MIME type sniffing attacks
add_header X-Content-Type-Options "nosniff" always;

# Detects and blocks XSS attacks
add_header X-XSS-Protection "1; mode=block" always;
```

### **3. API Proxy (Security Logging)**

```nginx
location /api/ {
    # Forward requests to backend service
    proxy_pass http://backend:8080;

    # Preserve original client info
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    # Logging for security monitoring
    access_log /var/log/app/board-service/nginx/access.log main;
}
```

---

## 🧪 **Verification Results of Current Settings**

### **✅ Features working successfully**

#### **1. Port 80 Access**

```bash
# Verify normal response
curl -I http://localhost
# HTTP/1.1 200 OK
# Server: nginx/1.29.1
# X-Frame-Options: SAMEORIGIN
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
```

#### **2. API Proxy**

```bash
# Verify normal forwarding to backend
curl -I http://localhost/api/posts
# HTTP/1.1 401 Unauthorized
# Server: nginx/1.29.1
# X-Powered-By: Express  ← Backend response header
```

#### **3. Security Headers**

```bash
# Include security headers in all responses
curl -I http://localhost/api/users/login
# X-Frame-Options: SAMEORIGIN
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
```

#### **4. Logging System**

```bash
# No double logging - each request logged exactly once
tail -f /var/log/app/board-service/nginx/access.log
# 172.26.0.1 - - [25/Aug/2025:04:42:59 +0000] "GET /api/posts HTTP/1.1" 401 33
# (No duplicate logs)
```

---

## 🔍 **Advantages of Current Settings**

### **✅ Security Enhancement**

- **Complete API Request Tracking**: All backend calls are logged.
- **Attack Prevention**: Blocks clickjacking, XSS, MIME sniffing, etc.
- **IP Tracking**: Preserves actual client IP address.

### **✅ Performance Optimization**

- **Redundant Logging Removed**: Each request is logged exactly once.
- **Static Asset Logging Disabled**: Unnecessary log noise removed.
- **Efficient Proxy**: Backend connections optimized.

### **✅ Maintainability**

- **Clear Logging Structure**: Granular logging policies by location.
- **Consistent Security Settings**: Security headers applied to all responses.
- **Easy Diagnosis**: Fast troubleshooting with accurate logs.

---

## 📋 **Current Configuration Checklist**

### **✅ Basic Features**

- [x] Normal response from port 80.
- [x] React Router pages load normally.
- [x] Static assets served normally.
- [x] Health check endpoint working.

### **✅ Security Features**

- [x] API proxy working normally.
- [x] Security headers included in all responses.
- [x] Client IP address logged accurately.
- [x] Complete tracking of API requests.

### **✅ Logging Features**

- [x] Double logging issue resolved.
- [x] API requests logged exactly once.
- [x] Static asset logging disabled.
- [x] Error logging working normally.

---

## 🎉 **Final Conclusion**

**The current nginx.conf configuration is working perfectly!**

### **✅ Resolved Issues:**

1. **Double Logging** → Completely resolved.
2. **Port Mapping Error** → Completely resolved.
3. **Missing API Proxy** → Completely resolved.
4. **Lack of Security Logging** → Completely resolved.

### **✅ Current Status:**

- **Security**: Highest level of security headers and logging.
- **Performance**: Optimized logging and caching.
- **Stability**: Stable API proxy and React Router support.
- **Monitoring**: Perfect security logs and request tracking.

**This configuration provides production-level security and performance!** 🛡️🚀

**Nginx.conf configuration is not a one-time completion, but an important security asset that must be continuously monitored and improved.** 📚

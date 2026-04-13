# Board Service - Frontend

This project serves as the frontend application for the Board Service. It is built using modern web technologies including React, TypeScript, and Material-UI (MUI).

## 🚀 Technologies

- **React 19** - UI Library
- **TypeScript** - Static type checking for JavaScript
- **Material-UI (MUI) v7** - UI component library
- **React Router v7** - Routing and navigation
- **Axios** - Promise-based HTTP client for API communication
- **Emotion** - CSS-in-JS styling library

## 📦 Project Structure

Based on the architectural design, the project follows this standard directory structure:

```text
src/
├── api/          # API integration and server communication logic
├── components/   # Reusable, presentation-focused UI components
├── containers/   # State-aware container components
├── contexts/     # React Context API for global state management
├── hooks/        # Custom React hooks (e.g., data fetching, logic)
├── routes/       # Application routing and page structure
├── App.tsx       # Root application component
└── index.tsx     # Application entry point
```

## 🛠 Available Scripts

In the project directory, you can run the following commands:

### `npm start`

Runs the application in development mode.
Open [http://localhost:3000](http://localhost:3000) to view it in the browser.
The page will dynamically reload if you make edits. You will also see any linting errors in the console.

### `npm test`

Launches the test runner in interactive watch mode.
See the Create React App documentation about [running tests](https://facebook.github.io/create-react-app/docs/running-tests) for more information.

### `npm run build`

Builds the application for production to the `build` folder.
It correctly bundles React in production mode and optimizes the build for the best performance. The output is minified and filenames include cache-busting hashes.

### `npm run eject`

**Note: this is a one-way operation. Once you `eject`, you can't go back!**
If you aren't satisfied with the build tool and configuration choices, you can `eject` at any time. This command will remove the single build dependency from your project.

## 📖 React Learning Notes

*Note: The previous version of this README contained extensive Korean notes on React fundamentals (Components, Props, Hooks like `useState` / `useEffect` / `useCallback`, Hooks concepts, async/await, etc.). If you still need those tutorials, please recover them from your git history, as this file has been updated to reflect the standard project-level English documentation format.*
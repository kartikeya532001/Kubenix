import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App"; // import App instead of ChatApp
import { ThemeProvider } from "@mui/material/styles";
import { theme } from "./theme/theme";
import CssBaseline from "@mui/material/CssBaseline";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <App /> {/* render App here */}
    </ThemeProvider>
  </React.StrictMode>
);

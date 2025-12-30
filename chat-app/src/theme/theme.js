import { createTheme } from "@mui/material/styles";

export const theme = createTheme({
  palette: {
    mode: "light",
    primary: {
      main: "#4caf50",
    },
    secondary: {
      main: "#2196f3",
    },
    background: {
      default: "linear-gradient(to bottom, #f5f7fa, #c3cfe2)",
      paper: "#ffffff",
    },
  },
  typography: {
    fontFamily: "'Roboto', sans-serif",
  },
});

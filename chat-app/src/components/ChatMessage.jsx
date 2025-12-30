import React from "react";
import { Box, Typography } from "@mui/material";

const ChatMessage = ({ message }) => {
  const isUser = message.sender === "user";

  return (
    <Box
      sx={{
        display: "flex",
        justifyContent: isUser ? "flex-end" : "flex-start",
        mb: 1,
      }}
    >
      <Box
        sx={{
          maxWidth: "75%",
          p: 1.5,
          borderRadius: 2,
          bgcolor: isUser ? "primary.main" : "secondary.main",
          color: "#fff",
          wordBreak: "break-word",
          boxShadow: 2,
        }}
      >
        <Typography variant="body1">{message.text}</Typography>
        <Typography variant="caption" sx={{ float: "right", mt: 0.5 }}>
          {message.time}
        </Typography>
      </Box>
    </Box>
  );
};

export default ChatMessage;

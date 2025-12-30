import React, { useEffect, useRef } from "react";
import { Box } from "@mui/material";
import ChatMessage from "./ChatMessage";

const ChatWindow = ({ messages }) => {
  const scrollRef = useRef();

  useEffect(() => {
    scrollRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  return (
    <Box
      sx={{
        height: "400px",
        overflowY: "auto",
        p: 2,
        mb: 2,
        borderRadius: 2,
      }}
    >
      {messages.map((msg, index) => (
        <ChatMessage key={index} message={msg} />
      ))}
      <div ref={scrollRef} />
    </Box>
  );
};

export default ChatWindow;

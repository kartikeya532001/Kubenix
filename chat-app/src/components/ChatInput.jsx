import React from "react";
import { Box, TextField, IconButton } from "@mui/material";
import SendIcon from "@mui/icons-material/Send";

const ChatInput = ({ question, setQuestion, sendQuestion }) => {
  const handleKeyPress = (e) => {
    if (e.key === "Enter") sendQuestion();
  };

  return (
    <Box sx={{ display: "flex", mt: 1 }}>
      <TextField
        fullWidth
        variant="outlined"
        placeholder="Type your question..."
        value={question}
        onChange={(e) => setQuestion(e.target.value)}
        onKeyPress={handleKeyPress}
      />
      <IconButton color="primary" onClick={sendQuestion}>
        <SendIcon />
      </IconButton>
    </Box>
  );
};

export default ChatInput;

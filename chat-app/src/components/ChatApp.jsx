import React, { useState, useEffect, useRef } from "react";
import axios from "axios";
import { Box, Typography, CircularProgress } from "@mui/material";
import ChatInput from "./ChatInput";
import ChatWindow from "./ChatWindow";

const ChatApp = () => {
  const [question, setQuestion] = useState("");
  const [messages, setMessages] = useState([]);
  const [jobs, setJobs] = useState([]);
  const completedJobs = useRef(new Set());

  const addMessage = (text, sender = "user") => {
    setMessages((prev) => [
      ...prev,
      { text, sender, time: new Date().toLocaleTimeString() },
    ]);
  };

  const sendQuestion = async () => {
    if (!question.trim()) return;

    addMessage(question, "user");

    try {
      const res = await axios.post("/api_v1/chat", {
        text: question,
        priority: "normal",
      });

      const newJob = {
        job_id: res.data.job_id,
        question,
        status: "queued",
      };

      setJobs((prev) => [...prev, newJob]);
      setQuestion("");
    } catch (err) {
      console.error(err);
      addMessage("Error sending question. Please try again.", "bot");
    }
  };

  // Polling for job results
  useEffect(() => {
    const interval = setInterval(async () => {
      const pendingJobs = jobs.filter((j) => j.status !== "done");
      if (!pendingJobs.length) return;

      const updates = await Promise.all(
        pendingJobs.map(async (job) => {
          try {
            const res = await axios.get(`/api_v1/result/${job.job_id}`);
            return {
              ...job,
              status: res.data.status,
              response: res.data.response,
            };
          } catch {
            return job;
          }
        })
      );

      setJobs((prev) =>
        prev.map((job) => {
          const updated = updates.find((u) => u.job_id === job.job_id);
          if (!updated) return job;

          if (
            updated.status === "done" &&
            updated.response &&
            !completedJobs.current.has(job.job_id)
          ) {
            addMessage(updated.response, "bot");
            completedJobs.current.add(job.job_id);
          }
          return updated;
        })
      );
    }, 2000);

    return () => clearInterval(interval);
  }, [jobs]);

  return (
    <Box
      sx={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "flex-start",
        p: 3,
        background: "linear-gradient(135deg, #74ebd5 0%, #ACB6E5 100%)",
      }}
    >
      <Box
        sx={{
          width: "100%",
          maxWidth: 600,
          bgcolor: "background.paper",
          p: 3,
          borderRadius: 3,
          boxShadow: 5,
        }}
      >
        <Typography variant="h4" align="center" gutterBottom>
          Presenting You...
        </Typography>

        <ChatWindow messages={messages} />

        {jobs.some((j) => j.status !== "done") && (
          <Box sx={{ display: "flex", justifyContent: "center", mb: 1 }}>
            <CircularProgress size={24} />
          </Box>
        )}

        <ChatInput
          question={question}
          setQuestion={setQuestion}
          sendQuestion={sendQuestion}
        />
      </Box>
    </Box>
  );
};

export default ChatApp;

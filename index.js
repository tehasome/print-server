const Redis = require("ioredis");
const { exec } = require("child_process");
const axios = require("axios");
const cron = require("node-cron");
require("dotenv").config();

const redis = new Redis({
    host: process.env.REDIS_HOST || "127.0.0.1",
    port: process.env.REDIS_PORT || 6379
});

const WEBHOOK_URL = process.env.WEBHOOK_URL || "http://your-laravel-server.com/api/scan/printer-status";
const API_KEY = process.env.WEBHOOK_API_KEY;

async function checkPrintJobs() {
    exec("lpstat -l -W completed", async (error, stdout, stderr) => {
        if (error || stderr) {
            console.error("Error fetching print jobs:", error || stderr);
            return;
        }

        const lines = stdout.trim().split("\n");

        let jobBlocks = [];
        let currentBlock = [];

        for (const line of lines) {
            if (/^\S+-\d+/.test(line)) {
                if (currentBlock.length > 0) jobBlocks.push(currentBlock);
                currentBlock = [];
            }
            currentBlock.push(line.trim());
        }

        if (currentBlock.length > 0) {
            jobBlocks.push(currentBlock);
        }

        let newJobs = [];

        for (const block of jobBlocks) {
            const header = block[0];
            const jobId = header.split(/\s+/)[0];

            // หาค่า Alerts
            const alertLine = block.find(line => line.startsWith("Alerts:"));
            let jobState = "unknown";

            if (alertLine) {
                if (alertLine.includes("job-canceled") || alertLine.includes("processing-to-stop-point")) {
                    jobState = "canceled";
                } else if (alertLine.includes("job-completed-successfully")) {
                    jobState = "completed";
                } else if (alertLine.includes("job-aborted")) {
                    jobState = "aborted";
                }
            }

            const redisKey = `sentJob:${jobId}`;
            const alreadySent = await redis.exists(redisKey);
            if (!alreadySent) {
                newJobs.push({ job_id: jobId, status: jobState });
                await redis.set(redisKey, jobState, "EX", 86400); // 24 ชม.
            }
        }

        if (newJobs.length > 0) {
            console.log("New jobs:", newJobs);
            const config = {
                headers: {
                    "Content-Type": "application/json",
                    "X-API-KEY": API_KEY
                }
            };
            axios.post(WEBHOOK_URL, { jobs: newJobs }, config)
                .then(response => console.log("Webhook sent:", response.data))
                .catch(err => console.error("Error sending webhook:", err.message));
        } else {
            console.log("No new jobs to report.");
        }
    });
}


cron.schedule("* * * * *", checkPrintJobs);
console.log("CUPS Monitor with Redis Started... Checking every minute.");
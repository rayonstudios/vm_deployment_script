import express from "express";
import { execSync } from "child_process";
import path from "path";
import "dotenv/config";

const app = express();
const port = 3001;

app.get("/status", (req, res) => {
  res.send("Server is running!");
});

app.get("/deploy", (req, res) => {
  const env = req.query.env || "dev";
  const scriptPath = path.join(__dirname, "../deploy_vm.sh");

  execSync(`bash ${scriptPath} ${env} ${process.env.REPO_URL}`, {
    stdio: "inherit",
  });
  res.send("Finished!");

  // const command = spawn(`bash ${scriptPath} ${env} ${process.env.REPO_URL}`);
  // command.stdout.on("data", (data) => {
  //   res.write(data);
  // });
  // command.stderr.on("data", (data) => {
  //   res.write(data);
  // });
  // command.on("error", (err) => {
  //   res.end(err.message);
  // });
  // command.on("exit", (code) => {
  //   res.end(`Finished with code: ${code}!`);
  // });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

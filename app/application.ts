import express from "express";

import multer = require("multer");
var upload = multer({ dest: "uploads/" });

export class Application {
  private app = express();

  version(): string {
    return "1.0";
  }

  start(): boolean {
    this.app.post("/photos/upload", upload.array("photos", 12), function(
      req,
      res,
      next
    ) {
      res.send("OK");
    });

    this.app.listen(3000);

    return true;
  }

  stop(): boolean {
    return true;
  }
}

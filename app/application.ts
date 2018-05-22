import express from "express";

import multer = require("multer");
import getRawBody from "raw-body";
import * as stream from "stream";

import clamav from "clamav.js";
import { RequestHandler } from "express-serve-static-core";
import { read } from "fs";

var upload = multer({
  storage: multer.memoryStorage()
});

export class Application {
  private app = express();

  version(): string {
    return "1.0";
  }

  start() {
    console.log("Application Started");
    this.app.post("/photos/upload", upload.single("photo"), function(
      req,
      res,
      next
    ) {
      const readStream = new stream.Readable();
      readStream.push(req.file.buffer);
      readStream.push(null);
      clamav
        .createScanner(3310, "127.0.0.1")
        .scan(readStream, function(err, object, malicious) {
          if (err) {
            console.log(object.path + ": " + err);
            next(err);
          } else if (malicious) {
            console.log(object.path + ": " + malicious + " FOUND");
            next(new Error("Virus Detected"));
          } else {
            console.log(object.path + ": OK");
            res.send("OK");
          }
        });
    });

    this.app.use(function(err, req, res, next) {
      if (err !== null) {
        console.log(err);
        res.send({ result: "fail", error: err.message });
      } else {
        next();
      }
    });

    this.app.listen(3000, function() {
      console.log("Server listening on port 3000");
    });
  }

  stop(): boolean {
    return true;
  }
}

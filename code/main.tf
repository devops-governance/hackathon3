/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# This is an example of infrastructure does change over different stages/environments. 
# The configuration is kept in the config folder and used to deploy to the relevant stage.

resource "local_file" "file" {
    content  = "${var.team}"
    filename = "${path.module}/${var.team}.txt"
}

resource "google_storage_bucket" "bucket" {
  project = "${var.project}"
  name          = "hackathon-site-${var.team}"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "file" {
  name   = "${var.team}.js"
  source = local_file.file.filename
  bucket = google_storage_bucket.bucket.name
}

data "google_iam_policy" "viewer" {
  binding {
    role = "roles/storage.objectViewer"
    members = [
        "allUsers",
    ] 
  }
}

resource "google_storage_bucket_iam_policy" "editor" {
  bucket = "${google_storage_bucket.bucket.name}"
  policy_data = "${data.google_iam_policy.viewer.policy_data}"
}

terraform {
    backend "s3" {
      bucket = "test-terrafom-556621"
      key = "tfstate-files/terraform.tfstate"
      region = "eu-central-1"
      dynamodb_table = "terraform-state-locking"
    }
}

resource "time_sleep" "wait_150_seconds" {
  create_duration = "150s"
}
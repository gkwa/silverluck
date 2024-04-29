{examples = [
    {
        source_url = "https://developer.hashicorp.com/packer/tutorials/aws-get-started/aws-get-started-build-image"
        hcl = r"""


packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}



    """
    }
    {
        notes = r"""

https://github.com/bketelsen/packer-plugin-incus?tab=readme-ov-file#packer-plugin-incus

      """
        hcl = r"""


packer {
 required_plugins {
   incus = {
     version = ">= 1.0.0"
     source  = "github.com/bketelsen/incus"
   }
   ansible = {
     version = "~> 1"
     source = "github.com/hashicorp/ansible"
   }
 }
}

source "incus" "jammy" {
 image        = "{{ image }}"
 output_image = "{{ output_image }}"
 container_name = "kindsealion"
 reuse        = true
 skip_publish = {{ skip_publish }}
}

build {
  sources = ["incus.jammy"]

  provisioner "file" {
    source      = "setup_networking.sh"
    destination = "/var/lib/cloud/scripts/per-boot/010_setup_netorking.sh"
    max_retries = 10
  }
  provisioner "shell" {
    inline = [
      "chmod +x /var/lib/cloud/scripts/per-boot/010_setup_netorking.sh",
    ]
  }

  provisioner "file" {
    source      = "{{ cloud_init }}"
    destination = "/etc/cloud/cloud.cfg.d/custom-cloud-init.cfg"
    max_retries = 10
  }

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
    ]
  }

  provisioner "shell" {
    scripts = [
      "provision.sh",
    ]
  }
}


    """
    }
]}

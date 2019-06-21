resource "aws_key_pair" "key" {
  key_name   = "key_web_app"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "aws_instance" "python_webapp_db" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "${var.dbip}"
  associate_public_ip_address = true

  tags = {
    Name = "Python Web App Database"
  }

  connection {
    user        = "centos"
    private_key = "${file("~/.ssh/id_rsa")}"
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/notes/db/db_setup.sh"
    destination = "/var/tmp/db_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash /var/tmp/db_setup.sh"
    ]
  }
}

resource "aws_instance" "python_webapp" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${var.subnet_id}"
  key_name                    = "${aws_key_pair.key.id}"
  vpc_security_group_ids      = "${var.security_group_id}"
  private_ip                  = "${var.webappip}"
  associate_public_ip_address = true
  depends_on                  = [aws_instance.python_webapp_db]

  tags = {
    Name = "Python Web App"
  }

  connection {
    user        = "centos"
    private_key = "${file("~/.ssh/id_rsa")}"
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/notes"
    destination = "/home/centos/"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/centos/notes/initapp.sh"
    ]
  }
}


output "DB_IP" {
  value = "${aws_instance.python_webapp_db.public_ip}"
}

output "APP_IP" {
  value = "${aws_instance.python_webapp.public_ip}"
}

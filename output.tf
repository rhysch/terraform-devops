## output of for each

output "ec2_IP" {
  value = [
    for instance in aws_instance.mine_ec2 : instance.public_ip
  ]
}

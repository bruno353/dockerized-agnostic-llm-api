# Agnostic Ollama API Setup

The main goal of this content is to provide users with a **seamless way to deploy their own LLM with an API interface on any cloud provider**, ensuring that you are not dependent on any internal services (such as AWS SageMaker). This allows you to maintain full control over your model while reducing costs at scale by avoiding third-party APIs.
</br>
</br>
Main.go file forked from [developersdigest](https://github.com/developersdigest/aws-ec2-cuda-ollama)
</br>
### Key technologies include:
- Ollama for LLM management and inference, enabling GPU and CPU support.
- Go (Golang) for building a fast and lightweight API service.
- Nginx for managing secure HTTPS connections and acting as a reverse proxy.
- Certbot for automatically obtaining and renewing SSL certificates from Let's Encrypt.
- Systemd to manage services like the LLM API and Ollama server as background processes.
</br>
For this tutorial example we are using the AWS g4 ec2 instance.
</br>
You will: Deploy your EC2 instance, create an Elastic IP, attach it to your domain, run the script with your environment variables, pull your preferred LLM, and start running your API.

## 0. Configure setup.sh ENVs

The following variables need to be set by you:
   - DOMAIN_NAME: Your API`s domain
   - API_KEY: Secret key to connect with your model through the API
   - EMAIL: Your email to link with certbot
   - MODEL_NAME: The [model](https://ollama.com/library) to run

## 1. Launch EC2 Instance and Elastic API

a. Launch EC2:
- AMI: Search for and select "Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04)"
- Instance type: g4dn.xlarge (4 vCPUs, 16 GiB Memory, 1 GPU)
- Network settings:
   - Allow SSH (port 22) from your IP
   - Allow HTTPS and HTTP connections

b. Configure Elastic IP:
- Under Network & Security in EC2, go to Elastic IPs
- Allocate an Elastic IP address and attach it to your newly created EC2 instance
- In your domain manager, link the created IP to the domain name you want to use for your API
  
## 2. Connect to EC2 Instance

```
ssh -i your-key.pem ubuntu@your-ec2-public-ip
```

## 3. Update System

```
sudo apt update && sudo apt upgrade -y
```

## 4. Install Go

```
sudo apt install -y golang-go
```

## 5. Install Ollama

```
curl -fsSL https://ollama.com/install.sh | sh
```

## 6. Clone Repository

```
git clone https://github.com/developersdigest/aws-ec2-cuda-ollama-api.git
cd aws-ec2-cuda-ollama-api
```

## 7. Start Ollama in Background

```
ollama serve 
```

## 8. Pull Your Model

```
ollama pull gemma2:2b
```

## 10. Set Up Systemd Service - Required for setting up the ENV
# Either you can run export ```API_KEY="your_secure_api_key_here" ``` on your OS or set the env in this server script.

Create service file:
```
sudo vim /etc/systemd/system/ollama-api.service
```

Add the following content:
```
[Unit]
Description=Ollama API Service
After=network.target

[Service]
ExecStart=/usr/bin/go run /home/ubuntu/aws-ec2-cuda-ollama-api/main.go
WorkingDirectory=/home/ubuntu/aws-ec2-cuda-ollama-api
User=ubuntu
Environment=API_KEY=your_secure_api_key_here
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```
sudo systemctl enable ollama-api.service
sudo systemctl start ollama-api.service
```

## 11. Test API

From your local machine:
```
curl http://ec2-your-ec2.amazonaws.com:8080/v1/chat/completions \
-H "Content-Type: application/json" \
-H "Authorization: Bearer demo" \
-d '{
  "model": "gemma2:2b",
  "messages": [
    {"role": "user", "content": "Tell me a story about a brave knight"}
  ],
  "stream": true
}'
```

## Troubleshooting

- Ensure EC2 instance is running
- Verify Go application is running
- Check port 8080 is open in EC2 security group
- Confirm Ollama is running and "gemma2:2b" model is available

To check service status:
```
sudo systemctl status ollama-api.service
```

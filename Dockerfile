# Railway Deployment Dockerfile                                                                                                                                          
   FROM python:3.11-slim                                                                                                                                                    
                                                                                                                                                                            
   WORKDIR /app                                                                                                                                                             
                                                                                                                                                                            
   # Install system dependencies                                                                                                                                            
   RUN apt-get update && apt-get install -y \                                                                                                                               
       gcc \                                                                                                                                                                
       && rm -rf /var/lib/apt/lists/*                                                                                                                                       
                                                                                                                                                                            
   # Copy requirements first for better caching                                                                                                                             
   COPY requirements.txt .                                                                                                                                                  
   RUN pip install --no-cache-dir -r requirements.txt                                                                                                                       
                                                                                                                                                                            
   # Copy bot files                                                                                                                                                         
   COPY telegram_bot.py ./                                                                                                                                                  
   COPY railway.json ./                                                                                                                                                     
                                                                                                                                                                            
   # Create non-root user                                                                                                                                                   
   RUN useradd -m -u 1000 botuser && chown -R botuser:botuser /app                                                                                                          
   USER botuser                                                                                                                                                             
                                                                                                                                                                            
   # Health check                                                                                                                                                           
   HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \                                                                                                 
     CMD python3 -c "import telegram; bot = telegram.Bot(token=os.environ['TELEGRAM_BOT_TOKEN']); print('OK')" || exit 1                                                    
                                                                                                                                                                            
   # Run the bot                                                                                                                                                            
   CMD ["python3", "telegram_bot.py"]

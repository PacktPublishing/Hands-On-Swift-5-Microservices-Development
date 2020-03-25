# Hands-On-Microservices-with-Swift-5
Hands-On Microservices with Swift 5, published by Packt!

# IMPORTANT NOTICE #
This code here is continually updated until Vapor 4. When Vapor 4 is fulled released the book will be updated as well, you will receive an updated version if you have ordered the eBook version.

# Using compoer-compose #
Make sure you have the `docker-compose.yml` updated to reflect your environment variables. 
For you to run any service using the `docker-compose.yml` you need to run the following commands:
```
docker-compose up db
```
Then use another terminal (or shell/bash) window to run:
```
docker-compose up migrate
docker-compose up app
```
This follows the standard Vapor docker-compose.yml and will get your app up and running.

# Change Log #
## 03/24/20: Chapter 7 Update ##
The `docker-compose.yml` is now working as expected with MySQL8. Small fixes within the service:
- A typo disabling `JWTMiddleware` from working in address routes.
- More sophisticated error management.
- Docker-compose update.
- Sample .env file is now provided: `.env_sample`

*PostgreSQL Version now available:* You can now also use PostgreSQL if you prefer that in chapter 7. Other chapters will follow.

## 03/15/20: Chapter 9 Update ##
The product service in chapter 9 is now compatible with the latest Vapor RC.

## 03/15/20: Chapter 7 Update ##
Minor bug fix since `CORSMiddleware` was initialized twice.

## 03/13/20: Chapter 7 Update ##
Code is now working with the latest RC. While going through the code and validating I'm finding places that need improvement (beyond just the RC update). 

Do not hesitate to reach out if you have improvements that make sense to you. 
It used to be that `ErrorMiddleware` would return errors automatically and nicely formatted. That is something we need to do ourselves now, I left the code very generic for now but I'm working on coming up with something better.

## 03/08/20: Chapter 5 + 6 Update ##
The template has been updated to work with the most recent version of Vapor and Fluent.

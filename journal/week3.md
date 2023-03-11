# Week 3 — Decentralized Authentication

## Technical tasks

- Setup Cognito User Pool

 ![userpool](./assets/createuserpool.png)
 
 #### AWS Amplify
 This is a development platform that offers a variety of tools and services for building scalable and secure cloud applications.
 It provides a set of client libraries and SDKs that can be used to connect frontend applications to backend services and enable real-time data synchronization.
 Amplify supports popular frontend frameworks and provides integrations with other AWS services such as AWS AppSync, AWS Lambda, and Amazon S3. It also includes features such as user authentication, authorization, and analytics, that help developers build secure and scalable applications quickly and easily.

- Installing AWS Amplify while in the frontend-react-js directory

```
npm i aws-amplify --save
```

- Configure .gitpod.yml to include the added package in the node modules

```
  - name: npm-init
    init: |
      cd /workspace/aws-bootcamp-cruddur-2023/frontend-react-js
      npm i --save \
        @opentelemetry/api \
        @opentelemetry/sdk-trace-web \
        @opentelemetry/exporter-trace-otlp-http \
        @opentelemetry/instrumentation-document-load \
        @opentelemetry/context-zone \
        aws-amplify
```


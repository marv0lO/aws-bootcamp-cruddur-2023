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

- Configure Amplify in the app.js file

```
  import { Amplify } from 'aws-amplify';

Amplify.configure({
  "AWS_PROJECT_REGION": process.env.REACT_APP_AWS_PROJECT_REGION,
  "aws_cognito_identity_pool_id": process.env.REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID,
  "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
  "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
  "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
  "oauth": {},
  Auth: {
    // We are not using an Identity Pool
    // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
    region: process.env.REACT_APP_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
    userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: process.env.REACT_APP_CLIENT_ID,   // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  }
});
```

- Add Amplify env vars to docker-compose.yml

```
      REACT_AWS_PROJECT_REGION: "${AWS_DEFAULT_REGION}"
      REACT_APP_AWS_COGNITO_REGION: "us-east-1"
      REACT_APP_AWS_USER_POOLS_ID: "us-east-1_gaNJfNm6K"
      REACT_APP_CLIENT_ID: ""
```

![cognitouser](./assets/createuser.png)

- Configuring display of components once user is logged in 

##### Homefeed.js

```
//Add this to the import block
import { Auth } from 'aws-amplify';

//replace existing checkAuth function with the following function
const checkAuth = async () => {
  Auth.currentAuthenticatedUser({
    // Optional, By default is false. 
    // If set to true, this call will send a 
    // request to Cognito to get the latest user data
    bypassCache: false 
  })
  .then((user) => {
    console.log('user',user);
    return Auth.currentAuthenticatedUser()
  }).then((cognito_user) => {
      setUser({
        display_name: cognito_user.attributes.name,
        handle: cognito_user.attributes.preferred_username
      })
  })
  .catch((err) => console.log(err));
};
```
This code adds the Auth object from the aws-amplify library to the import block and replaces an existing checkAuth function with a new one that uses Auth to check if the user is authenticated and retrieve their attributes.

##### ProfileInfo.js

```
//Add this to the import block
import { Auth } from 'aws-amplify';

//replace existing signOut function with the following function
  const signOut = async () => {
    try {
        await Auth.signOut({ global: true });
        window.location.href = "/"
    } catch (error) {
        console.log('error signing out: ', error);
    }
  }
```
This code adds the Auth object from the aws-amplify library to the import block and replaces an existing signOut function with a new one that uses Auth to sign the user out and redirect them to the home page.

##### SigninPage.js

```
import { Auth } from 'aws-amplify';

const onsubmit = async (event) => {
  setErrors('')
  event.preventDefault();
  Auth.signIn(email, password)
  .then(user => {
    localStorage.setItem("access_token", user.signInUserSession.accessToken.jwtToken)
    window.location.href = "/"
  })
  .catch(error => {
    if (error.code == 'UserNotConfirmedException') {
      window.location.href = "/confirm"
    }
    setErrors(error.message)
  });
  return false
}
```
This code imports the Auth object from the aws-amplify library and defines an onsubmit function that handles a form submission event.

- Manually verifying the user

```
aws cognito-idp admin-set-user-password --user-pool-id "us-east-1_EsWorbtLo" --username nickda --password REDACTED --permanent
```


![error calling calling cognito idp](./assets/error.png)

- verification email

![verification email](./assets/verificationemail.png)

![success login](./assets/successfullogin.png)

- Implementing Custom Signup, Confirmation and Recovery Page

##### Signup.js
```
const onsubmit = async (event) => {
  event.preventDefault();
  setErrors('');
  console.log('username', username);
  console.log('email', email);
  console.log('name', name);
  try {
    const { user } = await Auth.signUp({
      username: email,
      password: password,
      attributes: {
        name: name,
        email: email,
        preferred_username: username,
      },
      autoSignIn: {
        enabled: true,
      },
    });
    console.log(user);
    window.location.href = `/confirm?email=${email}`;
  } catch (error) {
    console.log(error);
    setErrors(error.message);
  }
  return false;
};
```

![verifying user on console](./assets/userverified.png)

##### Confirmation.js
```
const resend_code = async (event) => {
  setErrors('');
  try {
    await Auth.resendSignUp(email);
    console.log('Code resent successfully');
    setCodeSent(true);
  } catch (err) {
    console.log(err);
    if (err.message === 'Username cannot be empty') {
      setErrors('You need to provide an email in order to send Resend Activation Code.');
    } else if (err.message === 'Username/client id combination not found.') {
      setErrors('Email is invalid or cannot be found.');
    }
  }
};
```
![confirmation page](./assets/confirmationpage.png)

##### RecoverPage.js
```
const onsubmit_send_code = async (event) => {
  event.preventDefault();
  setErrors('');
  Auth.forgotPassword(username)
    .then((data) => setFormState('confirm_code'))
    .catch((err) => setErrors(err.message));
  return false;
};
```
This code defines an asynchronous onsubmit_send_code function that handles a form submission event.

```
const onsubmit_confirm_code = async (event) => {
  event.preventDefault();
  setErrors('');
  if (password === passwordAgain) {
    Auth.forgotPasswordSubmit(username, code, password)
      .then((data) => setFormState('success'))
      .catch((err) => setErrors(err.message));
  } else {
    setErrors('Passwords do not match');
  }
  return false;
};
```
Function returns false to prevent the form from being submitted.

![recover page](./assets/resetpassword.png)

- Cognito Backend Server Verify
Passing the JWT to HomeFeedPage.js file
```
const loadData = async () => {
    try {
      const backend_url = `${process.env.REACT_APP_BACKEND_URL}/api/activities/home`
      var startTime = performance.now()
      const res = await fetch(backend_url, {
        headers: {
          // ******Add JWT to request Header*******
          Authorization: `Bearer ${localStorage.getItem("access_token")}`
        },
        method: "GET"
      });
      // Other part of the method/function .....
  };
```
- Add CORS in app.py
```
cors = CORS(
    app,
    resources={r"/api/*": {"origins": origins}},
    headers=['Content-Type', 'Authorization'],
    expose_headers='Authorization',
    methods="OPTIONS,GET,HEAD,POST"
)
```
Placed a logger in the decorated data_home() function to see if a token is sent from the frontend whne authenticated user logs in.
Implemented an external library called Flask-AWSCognito to verify the token received.

- Import CognitoJwtToken and initialize in the app.py file

```
from lib.cognito_jwt_token import CognitoJwtToken, extract_access_token, TokenVerifyError

app = Flask(__name__)

#JWT Token
cognito_jwt_token = CognitoJwtToken(
                          user_pool_id = os.getenv("AWS_COGNITO_USER_POOLS_ID"), 
                          user_pool_client_id = os.getenv("AWS_COGNITO_CLIENT_ID"), 
                          region = os.getenv("AWS_DEFAULT_REGION")
                          )
```

- Modified data_home() method

```
@app.route("/api/activities/home", methods=['GET'])
def data_home():

  access_token = cognito_jwt_token.extract_access_token(request.headers)
  if access_token == "null": #empty accesstoken
    data = HomeActivities.run()
    return data, 200
  
  # If token isn't null
  try:
    cognito_jwt_token.verify(access_token)
    app.logger.debug("Authenicated")
    app.logger.debug(f"User: {cognito_jwt_token.claims['username']}")
    data = HomeActivities.run(cognito_user=cognito_jwt_token.claims['username'])
  except TokenVerifyError as e:
    app.logger.debug("Authentication Failed")
    app.logger.debug(e)
    data = HomeActivities.run()

  return data, 200
```
- Ensure the Jwt is removed when the user logs out by configuring the signout method in ProfileInfo.js

```
const signOut = async () => {
  try {
      await Auth.signOut({ global: true });
      window.location.href = "/"
      localStorage.removeItem("access_token") // Remove token when user logs out.
  } catch (error) {
      console.log('error signing out: ', error);
  }
}
```

## Homework Challenges



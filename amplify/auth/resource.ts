//import { defineAuth } from '@aws-amplify/backend';

/**
 * Define and configure your auth resource
 * @see https://docs.amplify.aws/gen2/build-a-backend/auth
 */
// export const auth = defineAuth({
//   loginWith: {
//     email: true,
//   },
// });


import { defineAuth, secret } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: true,
    externalProviders: {
      google: {
        clientId: secret('GOOGLE_CLIENT_ID'),
        clientSecret: secret('GOOGLE_CLIENT_SECRET'),
        scopes: ["email", "profile", "openid"],
      },
      // facebook: {
      //   clientId: secret("FACEBOOK_CLIENT_ID"),
      //   clientSecret: secret("FACEBOOK_CLIENT_SECRET"),
      //   scopes: ["email", "public_profile"],
      //   attributeMapping: {
      //     email: "email",
      //     familyName: "last_name",
      //     givenName: "first_name",
      //     fullname: "name",
      //   },
      // },
      callbackUrls: ['myapp://callback/'],
      logoutUrls: ['myapp://signout/'],
    },
  },
});




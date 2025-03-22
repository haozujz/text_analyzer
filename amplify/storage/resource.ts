import { defineStorage } from '@aws-amplify/backend';

export const storage = defineStorage({
    name: 'amplifyStorage',
    access: (allow) => ({
        'profile-pictures/*': [
            allow.guest.to(['read']),
            allow.authenticated.to(['read', 'write', 'delete'])
        ],
        'photo-submissions/*': [
            allow.guest.to(['read']),
            allow.authenticated.to(['read', 'write', 'delete'])
        ],
    })
});

// export const storage = defineStorage({
//     name: 'amplifyStorage',
//     access: (allow) => ({
//         'profile-pictures/{entity_id}/*': [
//             allow.guest.to(['read']),
//             allow.entity('identity').to(['read', 'write', 'delete'])
//         ],
//         'photo-submissions/{entity_id}/*': [
//             allow.entity('identity').to(['read', 'write', 'delete'])
//         ],
//     })
// });
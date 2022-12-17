const GhostAdminAPI = require('@tryghost/admin-api');
const api = new GhostAdminAPI({
    url: 'http://random-dev-domain.com',
    version: "v5.0",
    key: '6397ca72e0ea780001b49faf:ef47de045e25ae996d49d00e88c574cb9fc47c51a6e1a9d3b230321c82bf6cfd'
});
exports.handler =  async function(event, context) {
    let posts = await api.posts.browse();
    console.log(`Got ${posts['meta']['pagination']['total']} posts`)

    while (posts['meta']['pagination']['total'] != 0) {
        await Promise.all(
            posts.map( async p => 
                {
                    console.log(`Deleting post with id ${p.id} and title ${p.title}`)
                    return api.posts.delete({id: p.id});
                }
            )   
        )
        posts = await api.posts.browse();
    }
    return context.logStreamName
  }
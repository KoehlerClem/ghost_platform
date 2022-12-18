exports.handler =  async function(event, context) {
    const GhostAdminAPI = require('@tryghost/admin-api');
    const api = new GhostAdminAPI({
        url: 'http://random-dev-domain.com',
        version: "v5.0",
        key: event['ghost_Admin_API_key']
    });
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
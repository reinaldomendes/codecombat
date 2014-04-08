LevelSession = require('./LevelSession')
Handler = require('../../commons/Handler')
log = require 'winston'

TIMEOUT = 1000 * 30 # no activity for 30 seconds means it's not active

class LevelSessionHandler extends Handler
  modelClass: LevelSession
  editableProperties: ['multiplayer', 'players', 'code', 'completed', 'state',
                       'levelName', 'creatorName', 'levelID', 'screenshot',
                       'chat', 'teamSpells', 'submitted', 'unsubscribed']
  jsonSchema: require './level_session_schema'

  getByRelationship: (req, res, args...) ->
    return @getActiveSessions req, res if args.length is 2 and args[1] is 'active'
    return @sendNotFoundError(res)

  getActiveSessions: (req, res) ->
    return @sendUnauthorizedError(res) unless req.user.isAdmin()
    start = new Date()
    start = new Date(start.getTime() - TIMEOUT)
    query = @modelClass.find({'changed': {$gt: start}})
    query.exec (err, documents) =>
      return @sendDatabaseError(res, err) if err
      documents = (@formatEntity(req, doc) for doc in documents)
      @sendSuccess(res, documents)

  hasAccessToDocument: (req, document, method=null) ->
    return true if req.method is 'GET' and document.get('totalScore')
    super(arguments...)

module.exports = new LevelSessionHandler()

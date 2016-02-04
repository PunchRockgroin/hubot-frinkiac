# Description:
#   Frinkiac Search for hubot. Pretty basic, really.
#


class Frinkiac
  search_url: "https://www.frinkiac.com/api/search?q="
  img_url: "https://www.frinkiac.com/img"
  regex: /frinkiac me.*?([a-zA-Z0-9_\-\.\s]*)$/i

  constructor: (robot)->
    @robot = robot

  handleGet: (err, res, body) =>
    if (err)
      @msg.send "ERROR: #{err}"

    images = JSON.parse(body)
    if images?.length > 0
      image = @msg.random images
      @msg.send "#{@img_url}/#{image.Episode}/#{image.Timestamp}.jpg"
    else
      @msg.send "http://bukk.it/fail.jpg"

  responseHandler: (msg) =>
    @msg = msg
    @query = @msg.match[1]
    @robot.http("#{@search_url}#{encodeURIComponent(@query)}").get() @handleGet

module.exports = (robot) ->
  frinkiac = new Frinkiac(robot)
  robot.hear frinkiac.regex, frinkiac.responseHandler


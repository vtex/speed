ignoreReplace = [/\.js(\?.*)?$/, /\.css(\?.*)?$/, /\.svg(\?.*)?$/, /\.ico(\?.*)?$/,
                 /\.woff(\?.*)?$/, /\.png(\?.*)?$/, /\.jpg(\?.*)?$/, /\.jpeg(\?.*)?$/, /\.gif(\?.*)?$/, /\.pdf(\?.*)?$/]

# Middleware that replaces vtexcommercestable and vteximg for vtexlocal
# This enables the same proxy to handle both domains and avoid adding rules to /etc/hosts
replaceHtmlBody = (environment) -> (req, res, next) ->
  # Ignore requests to obvious non-HTML resources
  return next() if ignoreReplace.some (ignore) -> ignore.test(req.url)

  data = ''
  write = res.write
  end = res.end

  res.write = (chunk) ->
    data += chunk

  res.end = (chunk, encoding) ->
    if chunk
      data += chunk

    if data
      data = data.replace(new RegExp(environment, "g"), "vtexlocal")
      data = data.replace(new RegExp("vteximg", "g"), "vtexlocal")

    # Restore res properties
    res.write = write
    res.end = end
    res.end data, encoding

  next()

disableCompression = (req, res, next) ->
  req.headers['accept-encoding'] = 'identity'
  next()

errorHandler = (err, req, res, next) ->
  errString = err.code?.red ? err.toString().red
  console.log(errString, req.url.yellow)

module.exports =
  replaceHtmlBody: replaceHtmlBody
  disableCompression: disableCompression
  errorHandler: errorHandler

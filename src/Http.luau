local HttpService = game:GetService("HttpService")

local Promise = require(script.Parent.Parent.Promise)
local Sift = require(script.Parent.Parent.Sift)

local BASE_URL = "https://api.resend.com"

export type HttpMethod = "GET" | "POST" | "DELETE"

export type HttpRequest = {
	method: HttpMethod,
	path: string,
	headers: { [string]: string }?,
	body: string?,
}

export type HttpRequestWithoutMethod = {
	path: string,
	headers: { [string]: string }?,
	body: string?,
}

export type HttpResponse = {
	success: boolean,
	statusCode: number,
	statusMessage: string,
	headers: { [string]: string },
	body: string,
}

local Http = {}

local function request(self: Http, params: HttpRequest): Promise.TypedPromise<HttpResponse>
	return Promise.try(function()
		return HttpService:RequestAsync({
			Method = params.method,
			Url = `{BASE_URL}{params.path}`,
			Headers = Sift.Dictionary.merge({ Authorization = `Bearer {self.apiKey}` }, params.headers or {}),
			Body = params.body,
		})
	end):andThen(function(response)
		return {
			success = response.Success,
			statusCode = response.StatusCode,
			statusMessage = response.StatusMessage,
			headers = response.Headers,
			body = response.Body,
		}
	end)
end

local function get(self: Http, params: HttpRequestWithoutMethod): Promise.TypedPromise<HttpResponse>
	return self:request(Sift.Dictionary.merge({ method = "GET" }, params))
end

local function post(self: Http, params: HttpRequestWithoutMethod): Promise.TypedPromise<HttpResponse>
	return self:request(Sift.Dictionary.merge({ method = "POST" }, params))
end

local function delete(self: Http, params: HttpRequestWithoutMethod): Promise.TypedPromise<HttpResponse>
	return self:request(Sift.Dictionary.merge({ method = "DELETE" }, params))
end

function Http.new(apiKey: string)
	return {
		apiKey = apiKey,
		request = request,
		get = get,
		post = post,
		delete = delete,
	}
end

function Http.jsonEncode<T>(input: T): Promise.TypedPromise<string>
	return Promise.try(function()
		return HttpService:JSONEncode(input)
	end)
end

function Http.jsonDecode<T>(json: string): Promise.TypedPromise<T>
	return Promise.try(function()
		return HttpService:JSONDecode(json)
	end)
end

export type Http = typeof(Http.new(...))

return Http

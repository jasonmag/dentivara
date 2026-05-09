class ApiIdempotencyKey < ApplicationRecord
  validates :key, :http_method, :path, :request_hash, :response_code, :response_body, presence: true
end

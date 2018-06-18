require "shrine/storage/s3"

s3_options = {
    bucket:            "gofitness",
    access_key_id:     ENV["DIGITAL_OCEAN_SPACES_KEY"],
    secret_access_key: ENV["DIGITAL_OCEAN_SPACES_SECRET"],
    endpoint: 'https://nyc3.digitaloceanspaces.com',
    region: 'nyc3',
}

Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", upload_options: {acl: 'public-read'}, **s3_options), 
    store: Shrine::Storage::S3.new(prefix: "store", upload_options: {acl: 'public-read'}, **s3_options),
}


Shrine.plugin :activerecord
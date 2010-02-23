# --
# Copyright (C) 2008-2010 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ++

module Mongo

  # WARNING: This class is part of a new, experimental GridFS API. Subject to change.
  class Grid
    DEFAULT_FS_NAME = 'fs'

    def initialize(db, fs_name=DEFAULT_FS_NAME)
      raise MongoArgumentError, "db must be a Mongo::DB." unless db.is_a?(Mongo::DB)

      @db      = db
      @files   = @db["#{fs_name}.files"]
      @chunks  = @db["#{fs_name}.chunks"]
      @fs_name = fs_name

      @chunks.create_index([['files_id', Mongo::ASCENDING], ['n', Mongo::ASCENDING]])
    end

    def put(data, filename, opts={})
      opts.merge!(default_grid_io_opts)
      file = GridIO.new(@files, @chunks, filename, 'w', opts=opts)
      file.write(data)
      file.close
      file.files_id
    end

    def get(id)
      opts = {:query => {'_id' => id}}.merge!(default_grid_io_opts)
      GridIO.new(@files, @chunks, nil, 'r', opts)
    end

    def delete(id)
      @files.remove({"_id" => id})
      @chunks.remove({"_id" => id})
    end

    private

    def default_grid_io_opts
      {:fs_name => @fs_name}
    end
  end
end
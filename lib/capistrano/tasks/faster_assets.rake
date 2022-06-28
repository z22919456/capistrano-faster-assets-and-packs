# Original source: https://coderwall.com/p/aridag
# Original Gem: https://github.com/capistrano-plugins/capistrano-faster-assets
# Original PR: https://github.com/AutoUncle/capistrano-faster-assets

# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w[app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb]
set :webpack_dependencies, %w[app/javascript yarn.lock package-lock.json]
set :force_precompile, false
set :webpack_entry_path, 'packs'

# clear the previous precompile task
Rake::Task['deploy:assets:precompile'].clear_actions
class PrecompileRequired < StandardError; end
class WebpackCompileRequired < StandardError; end

namespace :deploy do
  namespace :assets do
    desc 'Precompile assets'
    task :precompile do
      on roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            raise PrecompileRequired, 'A forced precompile was triggered' if fetch(:force_precompile)

            # find the most recent release
            latest_release = capture(:ls, '-xr', releases_path).split[1]

            # precompile if this is the first deploy
            raise PrecompileRequired, 'Fresh deployment detected (no previous releases present)' unless latest_release

            latest_release_path = releases_path.join(latest_release)

            # precompile if the previous deploy failed to finish precompiling
            begin
              execute(:ls, latest_release_path.join('assets_manifest_backup'))
            rescue StandardError
              raise PrecompileRequired,
                    'The previous deployment does not have any assets_manifest_backup this indicates precompile was not successful'
            end

            ### Check Assets

            fetch(:assets_dependencies).each do |dep|
              release = release_path.join(dep)
              latest = latest_release_path.join(dep)

              # skip if both directories/files do not exist
              next if [release, latest].map { |d| test "[ -e #{d} ]" }.uniq == [false]

              # execute raises if there is a diff
              begin
                execute(:diff, '-Nqr', release, latest)
              rescue StandardError
                raise PrecompileRequired, "Found a difference between the current and the new version of: #{dep}"
              end
            end

            # copy over all of the assets from the last release
            release_asset_path = release_path.join('public', fetch(:assets_prefix))
            # skip if assets directory is symlink
            begin
              execute(:test, '-L', release_asset_path.to_s)
            rescue StandardError
              execute(:cp, '-r', latest_release_path.join('public', fetch(:assets_prefix)), release_asset_path.parent)
            end

            # check that the manifest has been created correctly, if not
            # trigger a precompile
            begin
              # Support sprockets 2
              execute(:ls, release_asset_path.join('manifest*'))
            rescue StandardError
              begin
                # Support sprockets 3
                execute(:ls, release_asset_path.join('.sprockets-manifest*'))
              rescue StandardError
                raise PrecompileRequired, 'No sprockets-manifest found'
              end
            end

            ### Check Webpack
            fetch(:webpack_dependencies).each do |dep|
              release = release_path.join(dep)
              latest = latest_release_path.join(dep)

              # skip if both directories/files do not exist
              next if [release, latest].map { |d| test "[ -e #{d} ]" }.uniq == [false]

              # execute raises if there is a diff
              begin
                execute(:diff, '-Nqr', release, latest)
              rescue StandardError
                raise WebpackCompileRequired, "Found a difference between the current and the new version of: #{dep}"
              end
            end

            # copy over all of the packs from the last release
            release_webpack_path = release_path.join('public', fetch(:webpack_entry_path))
            # skip if packs directory is symlink
            begin
              execute(:test, '-L', release_webpack_path.to_s)
            rescue StandardError
              begin
                # check that the packs of the last release has been created, or trigger a webpack compile
                execute(:cp, '-r', latest_release_path.join('public', fetch(:webpack_entry_path)),
                        release_webpack_path.parent)
              rescue StandardError
                raise WebpackCompileRequired, 'No latest packs found'
              end
            end

            # check that the webpack manifest has been created correctly, if not
            # trigger a webpack compile
            begin
              execute(:ls, release_webpack_path.join('manifest*'))
            rescue StandardError
              raise WebpackCompileRequired, 'No webpack manifest found'
            end

            info('Skipping webpack precompile, no asset diff found')
          rescue PrecompileRequired => e
            warn(e.message)
            execute(:rake, 'assets:precompile')
          rescue WebpackCompileRequired => e
            warn(e.message)
            execute(:rake, 'yarn:install')
            execute(:rake, 'webpacker:compile')
          end
        end
      end
    end
  end
end

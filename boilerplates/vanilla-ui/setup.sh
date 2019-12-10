#! /usr/bin/zsh

command -v npm > /dev/null 2>&1 || {
  echo '"npm" could not be found. Exiting the setup.'
  exit 1;
}

if [ $# -eq 0 ] || [ -z "$1" ]; then
  echo 'Please pass name of project. Exiting the setup.'
  exit 1;
fi

bppath=$HOME/Documents/softwares/.dotfiles/boilerplates/vanilla-ui

echo >&2 '***** Creating directories *****'
mkdir -pv $1/{dist/assets/{images,scripts,styles},src/{scripts,styles}}
cd $1

echo >&2 ''
echo >&2 '***** Initializing directory as NPM package *****'
npm init -y

echo >&2 ''
echo >&2 '***** Copying development files *****'
cp $bppath/_babelrc .babelrc
cp $bppath/_eslintignore .eslintignore
cp $bppath/_eslintrc .eslintrc
cp $bppath/postcss.config.js .
cp $bppath/webpack.config.js .

echo >&2 ''
echo >&2 '***** Adding development packages *****'
npm install --save-dev @babel/core \
                       babel-loader \
                       @babel/preset-env \
                       cross-env \
                       css-loader \
                       cssnano \
                       file-loader \
                       live-server \
                       mini-css-extract-plugin \
                       node-sass \
                       npm-run-all \
                       postcss-loader \
                       postcss-preset-env \
                       sass-loader \
                       webpack \
                       webpack-cli

echo >&2 ''
echo >&2 '***** Add the following scripts to package.json *****'
echo >&2 '"dev:assets": "webpack --watch"'
echo >&2 '"dev:start": "live-server --no-browser --open=./dist/ --host=localhost --watch=./dist/"'
echo >&2 '"dev": "npm-run-all -p dev:*"'
echo >&2 '"build": "cross-env NODE_ENV=production webpack"'

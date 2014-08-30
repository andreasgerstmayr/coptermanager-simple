var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var del = require('del');
var gulpFilter = require('gulp-filter');
var stylus = require('gulp-stylus');
var rename = require('gulp-rename');
var mainBowerFiles = require('main-bower-files');
var concat = require('gulp-concat');

var paths = {
  index: './src/index.coffee',
  client: './src/client/**/*.coffee',
  server: ['./src/server/**/*.coffee', '!./src/server/static/**'],
  scripts: './src/server/static/coffee/**/*.coffee',
  stylesheets: './src/server/static/stylus/**/*.styl',
  templates: './src/server/views/**/*.html',
  images: './src/server/static/images/**/*'
};

gulp.task('clean', function(cb) {
  del(['./lib'], cb);
});

gulp.task('index', function() {
  return gulp.src(paths.index)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./lib'));
});

gulp.task('client', function() {
  return gulp.src(paths.client)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./lib/client'));
});

gulp.task('server', function() {
  return gulp.src(paths.server)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./lib/server'));
});

gulp.task('scripts', function() {
  return gulp.src(paths.scripts)
    .pipe(coffee().on('error', gutil.log))
    .pipe(concat('scripts.js'))
    .pipe(gulp.dest('./lib/server/public/javascripts'));
});

gulp.task('stylesheets', function() {
  return gulp.src(paths.stylesheets)
    .pipe(stylus())
    .pipe(concat('styles.css'))
    .pipe(gulp.dest('./lib/server/public/stylesheets'));
});

gulp.task('templates', function() {
  return gulp.src(paths.templates)
    .pipe(gulp.dest('./lib/server/views'));
});

gulp.task('images', function() {
  return gulp.src(paths.images)
    .pipe(gulp.dest('./lib/server/public/images'));
});

gulp.task('bower', function() {
  var jsFilter = gulpFilter('**/*.js');
  var cssFilter = gulpFilter('**/*.css');
  var fontFilter = gulpFilter('**/fonts/*');
  return gulp.src(mainBowerFiles(), {base: './bower_components'})
    .pipe(jsFilter)
    .pipe(concat('vendor.js'))
    .pipe(gulp.dest('./lib/server/public/javascripts'))
    .pipe(jsFilter.restore())
    .pipe(cssFilter)
    .pipe(concat('vendor.css'))
    .pipe(gulp.dest('./lib/server/public/stylesheets'))
    .pipe(cssFilter.restore())
    .pipe(fontFilter)
    .pipe(rename({dirname: '.'}))
    .pipe(gulp.dest('./lib/server/public/fonts'));
});

gulp.task('build', ['index', 'client', 'server', 'scripts', 'stylesheets', 'templates', 'images', 'bower']);

gulp.task('watch', function() {
  gulp.watch(paths.index, ['index']);
  gulp.watch(paths.client, ['client']);
  gulp.watch(paths.server, ['server']);
  gulp.watch(paths.scripts, ['scripts']);
  gulp.watch(paths.stylesheets, ['stylesheets']);
  gulp.watch(paths.templates, ['templates']);
});

gulp.task('default', ['build', 'watch']);

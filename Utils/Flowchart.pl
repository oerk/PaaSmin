#!/usr/bin/env perl
use Text::Flowchart;

$flowchart = Text::Flowchart->new("width"    => 70,
                                  "directed" => 1);

$vm = $flowchart->box(
    "x_coord" => 20,
    "y_coord" => 0,

    #"y_pad"   => 2,
    "width"  => 45,
    "height" => 25
                     );

$system = $flowchart->box(
                          "string"  => "     ubuntu system          ",
                          "x_coord" => 20,
                          "y_coord" => 20,
                          "width"   => 45,
                          "height"  => 5
                         );

$docker = $flowchart->box(
                          "string"  => "docker server 80",
                          "x_coord" => 20,
                          "y_coord" => 2,
                          "width"   => 20,
                          "height"  => 18
                         );

$nginx = $flowchart->box(
                         "string"  => "web server 80",
                         "x_coord" => 45,
                         "y_coord" => 2,
                         "width"   => 20,
                         "height"  => 7
                        );

$ftp = $flowchart->box(
                       "string"  => "ftp server 21",
                       "x_coord" => 45,
                       "y_coord" => 9,
                       "width"   => 20,
                       "height"  => 5
                      );

$agent = $flowchart->box(
                         "string"  => "Agent  8081",
                         "x_coord" => 45,
                         "y_coord" => 14,
                         "width"   => 20,
                         "height"  => 6
                        );

$ngx = $flowchart->box(
                       "string"  => "nginx",
                       "x_coord" => 21,
                       "width"   => 18,
                       "y_coord" => 15,
                      );

$php = $flowchart->box(
                       "string"  => "php-fpm",
                       "x_coord" => 21,
                       "width"   => 18,
                       "y_coord" => 10,
                      );

$tomcat = $flowchart->box(
                          "string"  => "tomcat",
                          "x_coord" => 21,
                          "width"   => 18,
                          "y_coord" => 5,
                         );

$flowchart->relate([$nginx, "left", 10] => [$docker, "right", 8]);

$flowchart->draw();


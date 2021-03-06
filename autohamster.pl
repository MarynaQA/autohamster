#!perl
use strict; use warnings;
use utf8;
use AutoHamster::FoodEater;
use Data::Dump qw[dump];

my $HAMSTER_NUM = "038";

my @submitters_that_always_forget_to_put_AT_before_name = 
  qw(polusok);

my $form_at_info_topic = "Тема форума Automated-testing.info";
my $form_article_eng   = "Статья на английском";
my $form_article_rus   = "Статья на русском (украинском, белорусском)";
my $form_tool          = "Инструмент (приложение, проект, продукт)";
my $form_video         = "Видео";
my $form_forum         = "Обсуждение (Stackoverflow, Форум, Google Groups)";
my $form_slides        = "Слайды";
my $form_link_code     = "Ссылка на код/github gist",



my $cat_top_at   = ":new: Интересное на AT.Info",
my $cat_articles = ":paperclip: Статьи по автоматизации тестирования",
my $cat_code     = ":sparkles: Чудотворный  код";
my $cat_tools    = ":wrench: Инструменты";
my $cat_video    = ":video_camera: Видео по автоматизации тестирования";
my $cat_talks    = ":loudspeaker: Обсуждения";
my $cat_slides   = ":eyes: Слайды, презентации по автоматизации тестирования";
my $cat_other    = ":horse: И другое";


my @categories_order = 
(
    $cat_top_at,
    $cat_articles,
    $cat_tools,
    $cat_video,
    $cat_code,
    $cat_talks,
    $cat_slides,
    $cat_other,
);

my @feed_items = eat("food.txt");

my %content;


#   ________________________________
#  < After a short discussion with  >
#  < @DmitriyZverev and @polusok    >
#  < I've decided to verify the     >
#  < unique links. Thank to         >
#  < @DmitriyZverev for inspiring   >
#  < pull request.                  >
#   --------------------------------
#                         /
#                       /
#                c._
#      ."````"-"C  o'-.
#    _/   \       _..'
#   '-\  _/--.<<-'
#      `\)     \)  jgs
#

my %all_urls;
my $row = 0;

foreach my $item (@feed_items) 
{
    $row++;

    my $current_cat = $cat_other;
    my $item_cat = $item->{'category'};

    if ($item->{'submitter'})
    {
        if ( grep { $_ eq $item->{'submitter'} } @submitters_that_always_forget_to_put_AT_before_name )
        {
            $item->{'submitter'} = '@' . $item->{'submitter'};
        }
    }

    my $url = $item->{'url'};

    $all_urls{$url} = defined $all_urls{$url} ? $all_urls{$url} + 1 : 1;
    if ($all_urls{$url} > 1) 
    {
        warn "Found not unique link at row: $row:\n";
        warn "$url\n\n";
    }
    
    my $link = { 
                  title       => $item->{'title'},
                  url         => $item->{'url'},
                  description => $item->{'description'},
                  tags_line   => $item->{'tags_line'} ? $item->{'tags_line'} : "",
                  submitter   => $item->{'submitter'} ? "(Прислал(-а): $item->{'submitter'})" : "",
               };
    
    if ($item_cat eq  $form_article_eng              #        #
    ||  $item_cat eq  $form_article_rus)             ##########
    {                                                #        #
        $current_cat = $cat_articles;                ##########
    }                                                #        #
    elsif ($item_cat eq $form_tool)                  ##########
    {                                                #        #
        $current_cat = $cat_tools;                   ##########
    }                                                #        #
    elsif ($item_cat eq $form_video)                 ##########
    {                                                #        #
        $current_cat = $cat_video;                   ##########
    }                                                #        #
    elsif ($item_cat eq $form_forum)                 ##########
    {                                                #        #
        $current_cat = $cat_talks;                   ##########
    }                                                #        #
    elsif ($item_cat eq $form_at_info_topic)         ##########
    {                                                #        #
        $current_cat = $cat_top_at;                  ##########
    }                                                #        #
    elsif ($item_cat eq $form_slides)                ##########
    {                                                #        #
        $current_cat = $cat_slides;                  ##########
    }                                                #        #
    elsif ($item_cat eq $form_link_code)             ##########
    {                                                #        #
        $current_cat = $cat_code;                    ##########
    }                                                #        #
    
    $content{$current_cat} //= [];
    push @{ $content{$current_cat} }, $link;
    
}
open my $out, '>:utf8', "readme.md";

print $out qq[Дайджест полезных ссылок для тестировщиков-автоматизаторов #$HAMSTER_NUM \n\n];
print $out qq[<img src="http://automated-testing.info/uploads/default/249/8dc1c6206f895527.png">\n\n];

foreach my $category (@categories_order)
{
    next unless $content{$category};
    
    my @category_items = @{ $content{$category} };

    print $out "### $category\n";

    foreach my $item ( @category_items )
    {
        
        print $out "* [$item->{'title'}]($item->{'url'}) $item->{'submitter'} <br>";
        
        if ($item->{'tags_line'} !~ /^\s*$/) {
            print $out "<small><font color=\"gray\">$item->{'tags_line'}</font></small><br>";
        }

        if ($item->{'description'} !~ /^\s*$/) {
            print $out "$item->{'description'}<br>";
        }

        print $out "<br>\n";
    }

    print $out "\n\n";
    
    
}
print $out "---------------\n";

print $out <<EOF;
**Не хотите пропускать ничего интересного?** 
Подпишитесь на ленту [RSS Новости]( http://automated-testing.info/category/novosti.rss)  

И еще, **хотите добавить ссылку** в следующий дайджест?<br>
Тогда – **[сделайте это через специальную форму!](http://goo.gl/p8JpCx)** (Это – просто)   

И это ещё не всё! У нас и **букмарклет** есть, для быстрого добавления ссылок!   
Просто, зайдите на **[страницу букмарклета](http://dzhariy.github.io/at-info/special/hamster.html)** и перетащите ссылку в ваши закладки в браузере.  
После чего, нажимая на кнопку "+Atinfo.Hamster" – Вы сможете быстро добавить текущую страницу в следующий выпуск Автохомяка.   

---------
Смотрите также: [(Анонс) Automated Hamster: Ссылки для Автоматизаторов](http://automated-testing.info/t/anons-automated-hamster-ssylki-dlya-avtomatizatorov/3399)
EOF

close $out





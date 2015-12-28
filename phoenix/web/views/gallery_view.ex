defmodule PetePhoenix.GalleryView do
  use PetePhoenix.Web, :view

  def images do
    [
      {"pete_1", "https://flic.kr/p/9Yd37s"},
      {"pete_2", "https://flic.kr/p/xjFhnR"},
      {"pete_3", "https://flic.kr/p/nVP5fh"},
      {"pete_4", "https://flic.kr/p/vvC6hq"}
    ]
  end

end
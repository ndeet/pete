package main

import (
    "net/http"
    "html/template"
    "time"
    "log"
)

type Image struct {
    Name string
    Url string
}

func galleryHandler(t *template.Template) func(http.ResponseWriter, *http.Request) {
    return func(w http.ResponseWriter, r *http.Request) {
        data := map[int]Image {
            0 : {"pete_1", "https://flic.kr/p/9Yd37s"},
            1 : {"pete_2", "https://flic.kr/p/xjFhnR"},
            2 : {"pete_3", "https://flic.kr/p/nVP5fh"},
            3 : {"pete_4", "https://flic.kr/p/vvC6hq"},
        }

        err := t.ExecuteTemplate(w, "app", data)
        if err != nil {
            panic(err)
        }
    }
}

func main() {
    t := template.Must(template.ParseFiles("./views/app.html",
            "./views/gallery.html", "./views/image.html"))
    http.Handle("/assets/", http.StripPrefix("/assets/", http.FileServer(http.Dir("./assets"))))
    http.HandleFunc("/gallery", galleryHandler(t))
    srv := &http.Server {
        Addr: ":8080",
        ReadTimeout: 5 * time.Second,
        WriteTimeout: 10 * time.Second,
    }
    log.Println(srv.ListenAndServe())
}

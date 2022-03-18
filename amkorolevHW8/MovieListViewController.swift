//
//  ViewController.swift
//  amkorolevHW8
//
//  Created by Андрей Королев on 18.03.2022.
//

import UIKit

struct Movie {
    let title: String
    let posterPath: String
    let poster: UIImage?
}

class MovieViewController: UIViewController {
    
    private let tableView = UITableView()
    private let apiKey = "d6a99332ca5b317f9e1c0fc3c2801859"
    private var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.loadMovies()
        }
    }

    private func configureUI() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.register(MovieView.self, forCellReuseIdentifier: MovieView.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.reloadData()
    }
    
    private func loadMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/discover.movie?api_key=\(apiKey)&language=ruRu") else {
            return assertionFailure("error: url problem")
        }
        let session = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: { [weak self] data, _, _ in
            guard
                let data = data,
                let dict = try? JSONSerialization.jsonObject(with: data, options: .json5Allowed) as? [String: Any],
                let results = dict["results"] as? [[String: Any]]
            else { return }
            let movies: [Movie] = results.map { params in
                let title = params["title"] as! String
                let imagePath = params["poster_path"] as? String
                return Movie(title: title, posterPath: imagePath ?? "", poster: nil)
            }
            
            self?.movies = movies
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        })
        
        session.resume()
    }
}

extension MovieViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieView.identifier, for: indexPath) as! MovieView
        cell.configure(movie: movies[indexPath.row])
        return cell
    }
}

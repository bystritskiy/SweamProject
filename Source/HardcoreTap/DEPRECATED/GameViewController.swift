////
////  ViewController.swift
////
////  Created by Bogdan Bystritskiy on 10/11/17.
////  Copyright © 2017 Bogdan Bystritskiy. All rights reserved.
////
//
//import UIKit
//import Firebase
//import AudioToolbox
//import AVFoundation
//import GoogleMobileAds
//import GameKit
//import StoreKit
//
//class GameViewController: UIViewController, GADBannerViewDelegate, GKGameCenterControllerDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
//  
//  var bombSoundEffect: AVAudioPlayer? // Плеер звуков
//  
//  var count: Int = 0                 // Счетчик очков
//  
//  var seconds: Int = 0               // Счетчик секунд
//  var seconds100: Int = 0            // Счетчик десятых секунды
//  var fault = 0.10 {                  // Погрешность
//    didSet {
//      faultLabel.text = "Погрешность: \(fault)"
//    }
//  }
//  
//  var isHarcoreMode: Bool = false
//
//  var timer = Timer()
//  var flPlaying: Bool = false // Флаг запуска игры
//  var bgSound: Bool = true // Флаг проигрывание музыки
//  var timeStop = Date()
//  
//  let layerColors = [UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 0.6),
//                     UIColor(red: 0.5, green: 0.1, blue: 0.5, alpha: 0.6),
//                     UIColor(red: 0.5, green: 0.5, blue: 0.1, alpha: 0.6),
//                     UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 0.6),
//                     UIColor(red: 1.0, green: 0.5, blue: 1.0, alpha: 0.6),
//                     UIColor(red: 0.19, green: 0.91, blue: 0.74, alpha: 1.00),
//                     UIColor(red: 0.66, green: 0.40, blue: 0.93, alpha: 1.00),
//                     UIColor(red: 0.40, green: 0.93, blue: 0.47, alpha: 1.00),
//                     UIColor(red: 0.93, green: 0.56, blue: 0.40, alpha: 1.00),
//                     UIColor(red: 0.93, green: 0.40, blue: 0.67, alpha: 1.00),
//                     UIColor(red: 0.68, green: 0.92, blue: 0.00, alpha: 1.00),
//                     UIColor(red: 0.81, green: 0.85, blue: 0.40, alpha: 1.00),
//                     UIColor(red: 0.00, green: 0.90, blue: 0.46, alpha: 1.00),
//                     UIColor(red: 0.98, green: 0.75, blue: 0.18, alpha: 1.00)]
//  
//  let leftLayer = CAGradientLayer()
//  let rightLayer = CAGradientLayer()
//  
//  var rootRef = Database.database().reference()
//  var scoreRef: DatabaseReference!
//  let userDefaults = UserDefaults.standard
//  
//  @IBOutlet weak var switchModeGame: UISwitch!
//  
//  @IBOutlet weak var timerLabel: UILabel!
//  @IBOutlet weak var scoreLabel: UILabel!
//  @IBOutlet weak var highScoreLabel: UILabel!
//  @IBOutlet weak var faultLabel: UILabel!
//  
//  @IBOutlet weak var tapToRestartButton: UIButton!
//  @IBOutlet weak var startGameButton: UIButton!
//  @IBOutlet weak var shareButton: UIButton!
//  @IBOutlet weak var helloButtonWithPlayerName: UIButton!
//  @IBOutlet weak var hardcoreLabel: UIButton!
//  
//  var nameFromUserDefaults = " "
//  var highscoreFromUserDefaults: Int = 0
//  
//  @IBOutlet weak var bannerView: GADBannerView!
//  @IBOutlet weak var heightBannerView: NSLayoutConstraint!
//  
//  var productToPurshase = SKProduct()
//  
//  func buyDisableAd() {
//    print("Покупка = \(productToPurshase)")
//    let pay = SKPayment(product: productToPurshase)
//    SKPaymentQueue.default().add(self)
//    SKPaymentQueue.default().add(pay)
//  }
//  
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    
//    if SKPaymentQueue.canMakePayments() {
//      print("Покупки доступны")
//      let productID: Set<String> = ["1"]
//      let request = SKProductsRequest(productIdentifiers: productID)
//      request.delegate = self
//      request.start()
//    } else {
//      print("Покупки недоступны")
//    }
//    
//    authPlayerInGameCenter()
//    
//    bannerView.adUnitID = PrivateInfo.admobBannerID
//    bannerView.rootViewController = self
//    bannerView.load(GADRequest())
//    bannerView.delegate = self
//
//    // проверка проигрывания фоновой музыки
//    if userDefaults.bool(forKey: "bgSound") {
//      bgSound = true
//      userDefaults.set(bgSound, forKey: "bgSound")
//    } else {
//      bgSound = false
//      userDefaults.set(bgSound, forKey: "bgSound")
//    }
//    
//    //имя пользователя в левом вехнем углу
//    if let username = UserDefaults.standard.value(forKey: "userNAME") as? String {
//      self.nameFromUserDefaults = username
//    } else {
//      self.nameFromUserDefaults = " "
//    }
//    scoreRef = rootRef.child("leaderboards_normal").child(nameFromUserDefaults)
//    
//    //подгрузка рекорда из UserDefaults
//    if UserDefaults.standard.value(forKey: "highscore_normal") != nil {
//      self.highscoreFromUserDefaults = UserDefaults.standard.value(forKey: "highscore_normal") as! Int
//      highScoreLabel.text = "Ваш рекорд: \(self.highscoreFromUserDefaults)"
//    } else {
//      highScoreLabel.text = "Ваш рекорд: 0"
//    }
//    
//    // Регистрация рекогнайзера жестов
//    let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap))
//    view.addGestureRecognizer(tapGR)
//    
//    // Тень у кнопки
//    startGameButton.addShadow()
//    
//    self.navigationItem.title = "HardcoreTap"
//    self.helloButtonWithPlayerName.setTitle("Привет, \(self.nameFromUserDefaults)", for: .normal)
//    self.helloButtonWithPlayerName.isEnabled = false
//    
//    setupGALayers()
//    
//    view.layer.insertSublayer(rightLayer, at: 0)
//    view.layer.insertSublayer(leftLayer, at: 0)
//  }
//  
//  override func viewWillAppear(_ animated: Bool) {
//    //скрываем все лишнее, и ждем нажатия кнопки "Начать игру"
//    scoreLabel.isHidden = true
//    shareButton.isHidden = true
//    tapToRestartButton.isHidden = true
//    highScoreLabel.isHidden = true
//    
//    startGameButton.isHidden = false
//    switchModeGame.isHidden = false
//    hardcoreLabel.isHidden = false
//  }
//  
//  var gcEnable = Bool()
//  var gcDefaultLeaderboard = String()
//  
//  func authPlayerInGameCenter() {
//    let localePlayer: GKLocalPlayer = GKLocalPlayer.local
//    localePlayer.authenticateHandler = {viewController, error -> Void in
//      if viewController != nil {
//        self.present(viewController!, animated: true, completion: nil)
//      } else if localePlayer.isAuthenticated {
//        print("Local player already auth")
//        self.gcEnable = true
//        
//        // Get the default leaderboard ID
//        localePlayer.loadDefaultLeaderboardIdentifier(completionHandler: { leaderboardString, error in
//          if error == nil {
//            self.gcDefaultLeaderboard = leaderboardString!
//          }
//        })
//      } else {
//        print("Local player not auth. Disable Game center")
//        self.gcEnable = false
//      }
//    }
//  }
//  
//  func submitScoreOnGameCenter() {
//    let leaderboardID = "gamecenter-leaderboards"
//    let sScore = GKScore(leaderboardIdentifier: leaderboardID)
//    sScore.value = Int64(count)
//    GKScore.report([sScore]) { error in
//      if error != nil {
//        print(error!.localizedDescription)
//      } else {
//        print("Score submitted")
//      }
//    }
//  }
//  
//  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
//    gameCenterViewController.dismiss(animated: true, completion: nil)
//  }
//  
//  func setupGALayers() {
//    
//    rightLayer.colors = [layerColors[4].cgColor, UIColor(red: 61 / 255, green: 52 / 255, blue: 110 / 255, alpha: 0.0).cgColor]
//    rightLayer.startPoint = CGPoint(x: 0, y: 0)
//    rightLayer.endPoint = CGPoint(x: 0, y: 1)
//    rightLayer.frame = view.bounds
//    rightLayer.position.x = view.bounds.width + view.bounds.midX
//    
//    leftLayer.colors = [layerColors[0].cgColor, UIColor(red: 61 / 255, green: 52 / 255, blue: 110 / 255, alpha: 0.0).cgColor]
//    leftLayer.startPoint = CGPoint(x: 0, y: 0)
//    leftLayer.endPoint = CGPoint(x: 0, y: 1)
//    leftLayer.frame = view.bounds
//    leftLayer.position.x = view.bounds.midX
//    
//  }
//  
//  func changeLayers() {
//    rightLayer.colors![0] = leftLayer.colors![0]
//    
//    let index = (seconds + 1) % 5
//    leftLayer.colors![0] = layerColors[index].cgColor
//    
//    let animationRight = CABasicAnimation(keyPath: "position.x")
//    animationRight.fromValue = view.bounds.midX
//    animationRight.toValue = view.bounds.width + view.bounds.midX
//    animationRight.duration = 0.99
//    
//    let animationLeft = CABasicAnimation(keyPath: "position.x")
//    animationLeft.fromValue = -view.bounds.midX
//    animationLeft.toValue = view.bounds.midX
//    animationLeft.duration = 0.99
//    
//    rightLayer.add(animationRight, forKey: nil)
//    leftLayer.add(animationLeft, forKey: nil)
//  }
//  
//  @IBAction func switchModeDidTapped(_ sender: Any) {
//    if switchModeGame.isOn == false {
//      self.faultLabel.text = "Погрешность: от 0.05 мс"
//      isHarcoreMode = false
//      scoreRef = rootRef.child("leaderboards_normal").child(nameFromUserDefaults)
//    } else {
//      self.faultLabel.text = "Погрешность отключена"
//      isHarcoreMode = true
//      scoreRef = rootRef.child("leaderboards_hardcore").child(nameFromUserDefaults)
//    }
//  }
//  
//  @objc func didTap(tapGR: UITapGestureRecognizer) {
//    if flPlaying {
//      // Проверка точности попадания
//      if fabs(Double(seconds - count - 1) + Double(seconds100) / 100) <= fault + 0.0001 {
//        // Плюс очко
//        count += 1
//        scoreLabel.text = "\(count)"
//      } else {
//        self.gameOver()
//      }
//    } else {
//      // Задержка после проигрыша
//      // Если 0.4 секунды прошло, можно запускать
//      if timeStop.timeIntervalSinceNow <= -0.5 && startGameButton.isHidden {
//        self.setupGame()
//      }
//    }
//  }
//  
//  @IBAction func startGameButtonDidTapped(_ sender: Any) {
//    setupGame()
//  }
//  
//  func setupGame() {
//    let path = Bundle.main.path(forResource: "bmp60.mp3", ofType: nil)!
//    let url = URL(fileURLWithPath: path)
//    
//    do {
//      bombSoundEffect = try AVAudioPlayer(contentsOf: url)
//      if userDefaults.bool(forKey: "bgSound") {
//        bombSoundEffect?.play()
//      } else {
//        bombSoundEffect?.stop()
//      }
//    } catch {
//      // couldn't load file :(
//    }
//    
//    highScoreLabel.isHidden = false
//    scoreLabel.isHidden = false
//    highScoreLabel.isHidden = false
//    
//    shareButton.isHidden = true
//    startGameButton.isHidden = true
//    hardcoreLabel.isHidden = true
//    switchModeGame.isHidden = true
//    
//    count = 0
//    seconds = 0
//    seconds100 = 0
//    fault = switchModeGame.isOn ? 0.0 : 0.10
//    
//    flPlaying = true
//    
//    setupGALayers()
//    updateTimerLabel()
//    
//    scoreLabel.text = "\(count)"
//    
//    timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: timerBlock(timer:))
//    
//    changeLayers()
//  }
//  
//  func timerBlock(timer: Timer) {
//    seconds100 += 1
//    if seconds100 == 100 {
//      seconds += 1
//      seconds100 = 0
//      
//      if fault > 0.0501 {
//        fault -= 0.01
//      } else {
//        fault = 0.05
//      }
//      
//      changeLayers()
//    }
//    
//    updateTimerLabel()
//    
//    if Double(seconds - count - 1) + (Double(seconds100) / 100) > fault {
//      // Пропущено нажатие
//      gameOver()
//    }
//  }
//  
//  //нажали кнопку выйти
//  @IBAction func logOutButtonDidTapped(_ sender: Any) {
//    let alert: UIAlertController = UIAlertController()
//    let exitAction = UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in self.exitClicked() })
//    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
//    
//    alert.addAction(exitAction)
//    alert.addAction(cancelAction)
//    
//    self.present(alert, animated: true, completion: nil)
//    
//    //фон кнопки выход на алерте
//    let subView = alert.view.subviews.first!
//    let alertContentView = subView.subviews.first!
//    alertContentView.backgroundColor = UIColor.white
//    alertContentView.layer.cornerRadius = 15
//  }
//  
//  //нажали выход на алерте
//  func exitClicked() {
//    //удаление данных из UserDefaults
//    let defaults = UserDefaults.standard
//    defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
//    defaults.synchronize()
//    
//    //переход на страницу авторизации
//    let loginvc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
//    self.present(loginvc, animated: true, completion: nil)
//  }
//  
//  //конец игры
//  func gameOver() {
//    bombSoundEffect?.stop()
//    
//    timer.invalidate()
//    timeStop = Date()
//    flPlaying = false
//    
//    leftLayer.position.x = leftLayer.presentation()!.position.x
//    leftLayer.removeAllAnimations()
//    
//    rightLayer.position.x = rightLayer.presentation()!.position.x
//    rightLayer.removeAllAnimations()
//    
//    tapToRestartButton.isHidden = false
//    shareButton.isHidden = false
//    
//    //добавления нового рекорда
//    if count > highscoreFromUserDefaults {
//      
//      submitScoreOnGameCenter()
//      
//      highscoreFromUserDefaults = count
//      highScoreLabel.text = "Ваш рекорд: \(highscoreFromUserDefaults)"
//      UserDefaults.standard.set(highscoreFromUserDefaults, forKey: "highscore_normal")
//      
//      Message.shared.showMessage(
//        with: "🎉 Поздравляем!\nВы побили рекорд. Ваш новый результат \(count) очков",
//        type: .success
//      )
//    }
//    
//    let scoreItem = [
//      "username": nameFromUserDefaults,
//      "highscore": highscoreFromUserDefaults
//      ] as [String: Any]
//    
//    //отправка данных в Firebase
//    self.scoreRef.setValue(scoreItem)
//  }
//  
//  func updateTimerLabel() {
//    timerLabel.text = String(format: "00:%02d:%02d", seconds, seconds100)
//  }
//  
//  @IBAction func tapToRestartDidTapped(_ sender: Any) {
//    tapToRestartButton.isHidden = true
//    self.setupGame()
//  }
//  
//  //Кнопка поделиться
//  @IBAction func shareButtonDidTapped(_ sender: Any) {
//    let activityVC = UIActivityViewController(activityItems: ["Хэй, мой рекорд в HardcoreTap: \(self.highscoreFromUserDefaults). Попробуй набрать больше;) appstore.com/hardcoretap"], applicationActivities: nil)
//    activityVC.popoverPresentationController?.sourceView = self.view
//    self.present(activityVC, animated: true, completion: nil)
//  }
//  
//  /// Tells the delegate an ad request loaded an ad.
//  func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//    print("adViewDidReceiveAd")
//  }
//  
//  /// Tells the delegate an ad request failed.
//  func adView(_ bannerView: GADBannerView,
//              didFailToReceiveAdWithError error: GADRequestError) {
//    print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
//  }
//  
//  /// Tells the delegate that a full-screen view will be presented in response
//  /// to the user clicking on an ad.
//  func adViewWillPresentScreen(_ bannerView: GADBannerView) {
//    print("adViewWillPresentScreen")
//  }
//  
//  /// Tells the delegate that the full-screen view will be dismissed.
//  func adViewWillDismissScreen(_ bannerView: GADBannerView) {
//    print("adViewWillDismissScreen")
//  }
//  
//  /// Tells the delegate that the full-screen view has been dismissed.
//  func adViewDidDismissScreen(_ bannerView: GADBannerView) {
//    print("adViewDidDismissScreen")
//  }
//  
//  /// Tells the delegate that a user click will open another app (such as
//  /// the App Store), backgrounding the current app.
//  func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
//    print("adViewWillLeaveApplication")
//  }
//  
//  func sucessDisableAd() {
//    
//  }
//  
//  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//    print("productsRequest")
//    let myProduct = response.products
//    for product in myProduct {
//      print("Товар добавлен")
//      print("Товар id = \(product.productIdentifier)")
//      print(product.localizedTitle)
//      print(product.localizedDescription)
//    }
//  }
//  
//  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//    
//  }
//  
//}

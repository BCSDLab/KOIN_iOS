//
//  BusDetailViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 2024/03/29.
//

import Combine
import SnapKit
import UIKit

final class BusDetailViewController: UIViewController {
    // MARK: - Properties
    private var viewControllersForPaging = [UIViewController]()
    private var selectedTimetableIdx: BusType = .shuttleBus
    private var currentViewIdx : Int = 0 {
        didSet{
            var direction: UIPageViewController.NavigationDirection = .forward
            if oldValue >= self.currentViewIdx {direction = .reverse}
            self.pageViewController.setViewControllers([viewControllersForPaging[self.currentViewIdx]], direction: direction, animated: true)
            self.changeTab()
        }
    }
    
    // MARK: - UI Components
    private let tabBarView: UIView = {
        let tabBarView = UIView()
        tabBarView.backgroundColor = .clear
        return tabBarView
    }()
    
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        return pageViewController
    }()
    
    private let segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segment.insertSegment(withTitle: "운행정보", at: 0, animated: true)
        segment.insertSegment(withTitle: "운행정보검색", at: 1, animated: true)
        segment.insertSegment(withTitle: "시간표", at: 2, animated: true)
       
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        
        
        return segment
        
    }()
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemOrange
        return view
    }()
    // MARK: - Initialization
    init(selectedPage: (Int, BusType)) {
        self.currentViewIdx = selectedPage.0
        self.selectedTimetableIdx = selectedPage.1
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "버스/교통"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configure()
        setUpLayout()
        createPages()
        initPageViewController()
        self.segmentControl.addTarget(self, action: #selector(changeCurrentIndex), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .fill)
    }
    
}

extension BusDetailViewController {
    @objc private func changeCurrentIndex(control: UISegmentedControl) {
        self.currentViewIdx = control.selectedSegmentIndex
        let logValue: String
        switch control.selectedSegmentIndex {
        case 0:
            logValue = "운행정보"
        case 1:
            logValue = "운행정보검색"
        default:
            logValue = "시간표"
        }
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: MockAnalyticsService()))
        logAnalyticsEventUseCase.execute(label: EventParameter.EventLabel.Campus.busTabMenu, category: .click, value: logValue)
    }
    
    func initPageViewController(){
        pageViewController.setViewControllers([viewControllersForPaging[currentViewIdx]], direction: .forward, animated: true)
        self.segmentControl.selectedSegmentIndex = currentViewIdx
        self.currentViewIdx = segmentControl.selectedSegmentIndex
        changeTab()
    }
    
    func configure() {
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
    }
    
    private func changeTab() {
        let index = CGFloat(segmentControl.selectedSegmentIndex)
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let leadingDistance = segmentWidth * index

        UIView.animate(withDuration: 0.1, animations: {[weak self] in
            guard let self = self
            else {return}
            
            self.indicatorView.snp.updateConstraints{
                $0.leading.equalTo(self.segmentControl).inset(leadingDistance)
            }
            self.view.layoutIfNeeded()
        })
        
    }
    
    func createPages(){
        let logAnalyticsEventUseCase = DefaultLogAnalyticsEventUseCase(repository: GA4AnalyticsRepository(service: GA4AnalyticsService()))
        let busService = DefaultBusService()
        let busRepository = DefaultBusRepository(service: busService)
        let selectDepartureAndArrivalUseCase = DefaultSelectDepartAndArrivalUseCase()
        let fetchBusInfoUseCase = DefaultFetchBusInformationListUseCase(busRepository: busRepository)
        let searchBusInfoUseCase = DefaultSearchBusInfoUseCase(busRepository: busRepository)
        let fetchShuttleBusTimetableUseCase = DefaultFetchShuttleBusTimetableUseCase(busRepository: busRepository)
        let fetchExpressBusTimetableUseCase = DefaultFetchExpressTimetableUseCase(busRepository: busRepository)
        let fetchCityBusTimetableUseCase = DefaultFetchCityBusTimetableUseCase(busRepository: busRepository)
        
        let viewModel = BusViewModel(selectDepartureAndArrivalUseCase: selectDepartureAndArrivalUseCase, fetchBusInfoUseCase: fetchBusInfoUseCase, fetchShuttleBusTimetableUseCase: fetchShuttleBusTimetableUseCase, fetchExpressTimetableUseCase: fetchExpressBusTimetableUseCase, getShuttleBusFiltersUseCase: fetchShuttleBusTimetableUseCase, getExpressBusFiltersUseCase: fetchExpressBusTimetableUseCase, getCityBusFiltersUseCase: fetchCityBusTimetableUseCase, fetchCityTimetableUseCase: fetchCityBusTimetableUseCase, searchBusInfoUseCase: searchBusInfoUseCase, logAnalyticsEventUseCase: logAnalyticsEventUseCase)
        let v1 = BusInformationViewController(viewModel: viewModel)
        let v2 = SearchBusViewController(viewModel: viewModel)
        let v3 = BusTimetableViewController(viewModel: viewModel, busType: self.selectedTimetableIdx)
        
        viewControllersForPaging.append(v1)
        viewControllersForPaging.append(v2)
        viewControllersForPaging.append(v3)
        
    }
}

extension BusDetailViewController {
    func setUpLayout() {
        view.addSubview(tabBarView)
        tabBarView.addSubview(segmentControl)
        tabBarView.addSubview(indicatorView)
        view.addSubview(pageViewController.view)
        self.addChild(pageViewController)
    
        tabBarView.snp.makeConstraints{
            $0.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(48)
        }
        
        segmentControl.snp.makeConstraints{
            $0.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(46)
        }
        
        indicatorView.snp.makeConstraints{
            
            $0.top.equalTo(segmentControl.snp.bottom)
            $0.height.equalTo(2)
            $0.leading.equalTo(segmentControl)
            $0.width.equalTo(segmentControl.snp.width).dividedBy(segmentControl.numberOfSegments)
            
        }
        
        pageViewController.view.snp.makeConstraints{
            
            $0.top.equalTo(tabBarView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            
        }
    }
}
extension BusDetailViewController: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let vc = self.pageViewController.viewControllers?[0]
        guard let currentIndex = viewControllersForPaging.firstIndex(of: vc ?? UIViewController()) else {
            return
        }
        segmentControl.selectedSegmentIndex = currentIndex
        self.currentViewIdx = currentIndex
        print(segmentControl.selectedSegmentIndex)
    }
    
}
extension BusDetailViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllersForPaging.firstIndex(of: viewController) else {
            return nil
        }
        
        return currentIndex > 0 ? viewControllersForPaging[currentIndex-1] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllersForPaging.firstIndex(of: viewController) else {
            return nil
        }
        
        return currentIndex < (viewControllersForPaging.count-1) ? viewControllersForPaging[currentIndex+1] : nil
    }
    
    
}


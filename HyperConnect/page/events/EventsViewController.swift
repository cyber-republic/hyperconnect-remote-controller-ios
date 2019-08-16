
import UIKit
import CoreData

class EventsViewController: UIViewController {

    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var emptyPlaceholder: UIStackView!
    
    let pageIndex=2
    var eventResultsController:NSFetchedResultsController<Event>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initEventResultsController()
        eventsCollectionView.delegate=self
        eventsCollectionView.dataSource=self
        initPlaceholder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "actionAddEvent" {
            let addEventVC=segue.destination as! AddEventViewController
            addEventVC.fromPageIndex=pageIndex
        }
    }
    
    public func initPlaceholder() {
        if eventResultsController.sections?[0].numberOfObjects ?? 0 == 0 {
            eventsCollectionView.isHidden=true
            emptyPlaceholder.isHidden=false
        }
        else {
            eventsCollectionView.isHidden=false
            emptyPlaceholder.isHidden=true
        }
    }
    
    func initEventResultsController() {
        let fetchRequest:NSFetchRequest<Event>=Event.fetchRequest()
        let sortDescriptor=NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors=[sortDescriptor]
        eventResultsController=NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: LocalRepository.sharedInstance.getDataController().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        eventResultsController.delegate=self
        do{
            try eventResultsController.performFetch()
        }
        catch{}
    }
}


extension EventsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let event=eventResultsController.object(at: indexPath)
        let cell=eventsCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! EventsCollectionViewCell
        cell.bind(eventsVC: self, event: event)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CGFloat(245))
    }
}


extension EventsViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if eventsCollectionView.numberOfItems(inSection: 0) == 0 {
            if type == .insert {
                eventsCollectionView.insertItems(at: [newIndexPath!])
            }
        }
        else {
            eventsCollectionView.reloadData()
        }
        initPlaceholder()
    }
}

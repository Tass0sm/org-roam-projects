(require 'org-roam)
(require 'project)
(require 'consult)

(defun orp-node-get-create ()
  "Get or create org-roam node for current project"
  (interactive)
  (let* ((pr (project-current t))
         (title (project-name pr))
         (node-id (caar (org-roam-db-query
                         [:select id :from nodes
                                  :where (= title $s1)]
                         title))))
    (if node-id
        (org-roam-populate (org-roam-node-create :id node-id))
      (org-roam-node-create :title title))))

(defun orp-node-find ()
  "Open or start a capture for org-roam node."
  (interactive)
  (let* ((node (orp-node-get-create)))
    (if (and node (org-roam-node-file node))
        (org-roam-node-visit node)
      (org-roam-capture-
       :node node
       ;; :templates templates
       :props '(:finalize find-file)))))

(defun orp-capture ()
  "Capture an entry under the current project's org-roam node."
  (interactive)
  (let* ((node (orp-node-get-create))
         (id (org-roam-node-id node)))
    (org-roam-capture-
     :node node
     ;; TODO: refine interface and customization of templates
     :templates `(("t" "todo" entry nil
                   :target (node ,id))))))

(defun orp-consult-heading ()
  "Select a heading in the current project's org-roam node."
  (interactive)
  (let* ((node (orp-node-get-create))
         (file (org-roam-node-file node)))
    (find-file file)
    (consult-org-heading)))

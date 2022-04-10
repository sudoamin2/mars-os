#ifndef PROC_LIST_H
#define PROC_LIST_H

struct list {
  struct node *head;
  struct node *tail;
};

struct node {
  struct node *next;
};

void list_append(struct list *list, struct node *node);
struct node *list_remove_head(struct list *list);
struct node *list_remove(struct list *list, int wait);
bool list_is_empty(struct list *list);

#endif
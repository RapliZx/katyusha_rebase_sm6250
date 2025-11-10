/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _LINUX_TASK_WORK_H
#define _LINUX_TASK_WORK_H

#include <linux/list.h>
#include <linux/sched.h>

typedef void (*task_work_func_t)(struct callback_head *);

static inline void
init_task_work(struct callback_head *twork, task_work_func_t func)
{
	twork->func = func;
}

int task_work_add(struct task_struct *task, struct callback_head *twork, bool);
struct callback_head *task_work_cancel(struct task_struct *, task_work_func_t);
void task_work_run(void);

static inline void exit_task_work(struct task_struct *task)
{
	task_work_run();
}

/* Fallback untuk task_work flag */
#ifndef TWA_RESUME
#define TWA_RESUME false
#endif

/* Fallback untuk file_operations->fadvise */
#ifndef HAVE_F_OP_FADVISE
#define HAVE_F_OP_FADVISE 0
#endif

/* Fallback untuk copy_file_range (belum ada di kernel 4.14) */
#ifndef HAVE_COPY_FILE_RANGE
#define HAVE_COPY_FILE_RANGE 0
#define ksu_wrapper_copy_file_range ksu_wrapper_clone_file_range
#endif

#endif	/* _LINUX_TASK_WORK_H */

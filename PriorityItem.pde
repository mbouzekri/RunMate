public class PriorityItem implements Comparable<PriorityItem> {
    private int priority;
    private String value;

    public PriorityItem(int priority, String value) {
        this.priority = priority;
        this.value = value;
    }

    public int getPriority() {
        return priority;
    }

    public String getValue() {
        return value;
    }

    @Override
    public int compareTo(PriorityItem other) {
        return Integer.compare(this.priority, other.priority);
    }
}
